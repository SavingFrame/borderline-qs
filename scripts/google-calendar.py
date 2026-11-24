#!/usr/bin/env python3
"""Read-only Google Calendar bridge for Quickshell. Emits one JSON response."""

import argparse
import base64
from datetime import date, datetime, timedelta, timezone
import fcntl
import hashlib
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import os
from pathlib import Path
import secrets
import subprocess
import tempfile
import time
from urllib.error import HTTPError
from urllib.parse import parse_qs, quote, urlencode, urlsplit
from urllib.request import Request, urlopen

DATA = Path(os.environ.get("XDG_DATA_HOME") or Path.home() / ".local/share") / "borderline-qs"
CLIENT = DATA / "google-calendar-client.json"
TOKEN = DATA / "google-calendar-token.json"
LEGACY = "@legacy"
PREFETCH_MONTHS = 3
API = "https://www.googleapis.com/calendar/v3"
TOKEN_URL = "https://oauth2.googleapis.com/token"
SCOPES = ("https://www.googleapis.com/auth/calendar.calendarlist.readonly",
          "https://www.googleapis.com/auth/calendar.events.readonly")


class CalendarError(Exception):
    pass


def request_json(url, *, token=None, form=None, params=None):
    if params:
        url += "?" + urlencode(params)
    headers = {"Authorization": f"Bearer {token}"} if token else {}
    data = urlencode(form).encode() if form is not None else None
    with urlopen(Request(url, data=data, headers=headers), timeout=10) as response:
        return json.load(response)


def client_fields():
    try:
        client = json.loads(CLIENT.read_text())["installed"]
        return {key: client[key] for key in ("client_id", "client_secret")}
    except (OSError, ValueError, KeyError, TypeError):
        raise CalendarError("Add a Google Desktop OAuth client JSON file (see README).") from None


def read_accounts():
    try:
        stored = json.loads(TOKEN.read_text())
    except FileNotFoundError:
        return {}
    if "refresh_token" in stored:
        return {LEGACY: stored["refresh_token"]}
    return stored["accounts"]


def update_accounts(change):
    DATA.mkdir(mode=0o700, parents=True, exist_ok=True)
    # Each monitor has its own Calendar tab. Lock only the local read/modify/write.
    fd = os.open(DATA / "google-calendar.lock", os.O_CREAT | os.O_WRONLY, 0o600)
    with os.fdopen(fd, "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        accounts = read_accounts()
        change(accounts)
        if not accounts:
            TOKEN.unlink(missing_ok=True)
            return accounts
        file = tempfile.NamedTemporaryFile(mode="w", dir=DATA, delete=False)
        path = Path(file.name)
        try:
            with file:
                json.dump({"accounts": accounts}, file)
            path.replace(TOKEN)
        finally:
            path.unlink(missing_ok=True)
        return accounts


def account_label(key):
    return "Existing Google account" if key == LEGACY else key


def account_info(accounts):
    return [{"id": key, "label": account_label(key)} for key in accounts]


def authorize(client):
    state = secrets.token_urlsafe(32)
    verifier = secrets.token_urlsafe(64)
    challenge = base64.urlsafe_b64encode(hashlib.sha256(verifier.encode()).digest()).decode().rstrip("=")
    result = {}

    class Callback(BaseHTTPRequestHandler):
        def setup(self):
            self.request.settimeout(2)
            super().setup()

        def log_message(self, *_args):
            pass

        def do_GET(self):
            url = urlsplit(self.path)
            values = parse_qs(url.query)
            if url.path != "/callback" or not secrets.compare_digest(values.get("state", [""])[0].encode(), state.encode()):
                self.send_error(400, "Invalid sign-in callback")
                return
            result.update(values)
            self.send_response(200)
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.send_header("Cache-Control", "no-store")
            self.end_headers()
            self.wfile.write(b"You can close this tab and return to Borderline.")

    with HTTPServer(("127.0.0.1", 0), Callback) as server:
        server.timeout = 1
        redirect = f"http://127.0.0.1:{server.server_port}/callback"
        params = dict(client_id=client["client_id"], redirect_uri=redirect, response_type="code",
                      scope=" ".join(SCOPES), state=state, code_challenge=challenge,
                      code_challenge_method="S256", access_type="offline", prompt="select_account consent")
        url = "https://accounts.google.com/o/oauth2/v2/auth?" + urlencode(params)
        subprocess.Popen(["xdg-open", url], stdin=subprocess.DEVNULL,
                         stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)
        deadline = time.monotonic() + 180
        while not result and time.monotonic() < deadline:
            server.handle_request()

    if not result.get("code"):
        raise CalendarError("Google sign-in was declined or timed out.")
    response = request_json(TOKEN_URL, form=dict(client, code=result["code"][0],
                            code_verifier=verifier, redirect_uri=redirect, grant_type="authorization_code"))
    granted = response.get("scope", "").split()
    if (granted and not set(SCOPES).issubset(granted)) or not response.get("refresh_token"):
        raise CalendarError("Grant both read-only Calendar permissions to connect.")
    return response["access_token"], response["refresh_token"]


def access_token(client, refresh):
    try:
        response = request_json(TOKEN_URL, form=dict(client, refresh_token=refresh, grant_type="refresh_token"))
    except HTTPError as error:
        if error.code == 400 and json.load(error).get("error") == "invalid_grant":
            raise CalendarError("Google access expired. Disconnect and connect again.") from None
        raise
    return response["access_token"]


def pages(url, token, **params):
    while True:
        response = request_json(url, token=token, params=params)
        yield from response.get("items", [])
        if not response.get("nextPageToken"):
            return
        params["pageToken"] = response["nextPageToken"]


def epoch_ms(value):
    return int(datetime.fromisoformat(value.replace("Z", "+00:00")).timestamp() * 1000)


def calendar_list(token):
    return list(pages(API + "/users/me/calendarList", token, minAccessRole="reader",
                      fields="nextPageToken,items(id,summary,summaryOverride,selected,primary,backgroundColor)"))


def primary_id(calendars):
    return next((calendar["id"] for calendar in calendars if calendar.get("primary")), None)


def event_order(item):
    return not item["allDay"], item["start"]


def month_at(first, offset):
    years, month = divmod(first.month - 1 + offset, 12)
    return date(first.year + years, month + 1, 1)


def events(token, first, following, calendars, seen):
    # Cover the grid's spillover dates, with room for calendar timezone offsets.
    lower = datetime.combine(first - timedelta(days=8), datetime.min.time(), timezone.utc)
    upper = datetime.combine(following + timedelta(days=15), datetime.min.time(), timezone.utc)
    output = []
    for calendar in calendars:
        key = calendar["id"]
        if key in seen or not (calendar.get("primary") or calendar.get("selected")):
            continue
        endpoint = API + "/calendars/" + quote(key, safe="") + "/events"
        entries = pages(endpoint, token, timeMin=lower.isoformat(), timeMax=upper.isoformat(),
                        singleEvents="true", maxResults=2500, showDeleted="false",
                        fields="nextPageToken,items(summary,status,start(date,dateTime),end(date,dateTime))")
        for item in entries:
            if item.get("status") == "cancelled" or not item.get("start") or not item.get("end"):
                continue
            start, end = item["start"], item["end"]
            all_day = "date" in start
            output.append(dict(title=item.get("summary") or "Untitled event",
                               calendar=calendar.get("summaryOverride") or calendar.get("summary", ""),
                               color=calendar.get("backgroundColor", ""),
                               allDay=all_day,
                               start=start["date"] if all_day else epoch_ms(start["dateTime"]),
                               end=end["date"] if all_day else epoch_ms(end["dateTime"])))
        seen.add(key)
    return output


def merge_events(client, accounts, first, following, fresh):
    seen = set()
    output = []
    issues = []
    for account, refresh in accounts.items():
        label = account_label(account)
        try:
            token, calendars = fresh.get(account) or (None, None)
            if token is None:
                token = access_token(client, refresh)
                calendars = calendar_list(token)
            # Upgrade a previously connected single account without another sign-in.
            if account == LEGACY and (key := primary_id(calendars)):
                def migrate(stored):
                    if stored.get(LEGACY) == refresh:
                        del stored[LEGACY]
                        stored.setdefault(key, refresh)
                update_accounts(migrate)
            account_seen = set(seen)
            output.extend(events(token, first, following, calendars, account_seen))
            seen = account_seen
        except CalendarError as error:
            issues.append(f"{label}: {error}")
        except HTTPError as error:
            issues.append(f"{label}: Google Calendar request failed (HTTP {error.code}).")
        except (OSError, ValueError, KeyError, TypeError):
            issues.append(f"{label}: Could not load events.")
    return sorted(output, key=event_order), issues


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=("list", "connect", "disconnect"))
    parser.add_argument("month", type=date.fromisoformat, help="First day of the requested range")
    parser.add_argument("--months", type=int, choices=range(1, 7), default=PREFETCH_MONTHS,
                        help="Number of consecutive months to fetch")
    parser.add_argument("--account", help="Account ID to disconnect")
    args = parser.parse_args()
    first = args.month.replace(day=1)
    following = month_at(first, args.months)
    accounts = read_accounts()
    fresh = {}
    if args.action == "disconnect":
        if not args.account:
            parser.error("disconnect requires --account")
        accounts = update_accounts(lambda stored: stored.pop(args.account, None))
    elif args.action == "connect":
        client = client_fields()
        token, refresh = authorize(client)
        calendars = calendar_list(token)
        key = primary_id(calendars)
        if key is None:
            raise CalendarError("Could not identify this Google account's primary calendar.")
        accounts = update_accounts(lambda stored: stored.update({key: refresh}))
        fresh[key] = (token, calendars)
    output, issues = merge_events(client_fields(), accounts, first, following, fresh) if accounts else ([], [])
    return {"accounts": account_info(read_accounts()), "configured": CLIENT.is_file(),
            "months": [month_at(first, i).isoformat() for i in range(args.months)],
            "events": output, "warning": "\n".join(issues)}


if __name__ == "__main__":
    try:
        result = main()
    except CalendarError as error:
        result = {"error": str(error)}
    except HTTPError as error:
        result = {"error": f"Google Calendar request failed (HTTP {error.code})."}
    except (OSError, ValueError, TypeError, KeyError):
        result = {"error": "Could not connect to Google Calendar. Check the client file and network."}
    if "error" in result:
        try:
            result["accounts"] = account_info(read_accounts())
        except (OSError, ValueError, KeyError, TypeError):
            result["accounts"] = []
        result["configured"] = CLIENT.is_file()
    print(json.dumps(result))
