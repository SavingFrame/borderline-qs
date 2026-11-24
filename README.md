
# Borderline-qs

 │ Borderline-qs is a small, floating status bar and Control Center for Hyprland, built with Quickshell and inspired by Apple’s Dynamic Island.

 ### Features

 - Hyprland workspace indicators with app icons
 - A floating bar on each monitor
 - Clock, system tray, Wi-Fi and Ethernet status, Bluetooth status, and PipeWire volume

 ### Getting started

 Mention that it runs under Hyprland and uses Material Symbols Rounded for the status icons. Give readers a command they can try from the cloned repo:

 ```sh
   qs -p .
 ```

To install material symbols rounded font:
```sh
paru -S ttf-material-symbols-variable-git
```

 ### Control Center Home

 Click the center clock to open Home. Press Esc or click outside the Control Center to close it. It shows your username, hostname, system uptime, Hyprland version, local date and time, and the same Now Playing controls as the Sound tab. The volume and network icons still open their respective tabs directly.

 Home also has output volume and mute, a DDC/CI brightness slider, and quick toggles for Wi-Fi, Bluetooth, Caffeine, Night Light, and Do Not Disturb. The power button cycles through the available power profiles. Caffeine inhibits Wayland idle while the bar is running. Night Light requires a running `hyprsunset`. Do Not Disturb controls Borderline’s notification toasts. Power profiles require `power-profiles-daemon` and `powerprofilesctl`. Controls are disabled when their backend is unavailable.

 ### Notifications

 Click the bell to open the live inbox. App groups show their newest notification first. Click its message or **Show more** to reveal older messages, or **Show less** to collapse the stack. **Clear group** appears when the stack is expanded. Attached images appear as thumbnails alongside the message. Up to three toasts appear on the focused monitor when a stack starts. Toasts stay visible for seven seconds by default, or use the app’s requested timeout. Hover a toast to pause its timer. Drag a toast to the right and release to slide it off-screen, or right-click it. A short drag snaps back. Neither removes the inbox card. Do Not Disturb hides toasts without clearing or blocking the inbox, and the setting survives a restart. Notifications themselves do not. Borderline needs exclusive ownership of `org.freedesktop.Notifications` to receive them; stop or disable your other notification daemon before launching it.

 To try the inbox with sample cards without taking over the notification bus:

 ```sh
 BORDERLINE_NOTIFICATIONS_PREVIEW=1 qs -p .
 ```

 Notification sounds are off by default. Open the gear menu in the Notifications tab and use **Sound: Off** to enable them or **Test sound** to preview the built-in chime. Playback requires `canberra-gtk-play` (provided by `libcanberra` on Arch). New toasts use the app’s local sound file or sound-theme event when available, otherwise the built-in chime. DND and the `suppress-sound` hint silence automatic playback. Explicit sound tests bypass those settings. The bundled default is [Notification Sound 1 by deadrobotmusic](https://freesound.org/people/deadrobotmusic/sounds/750607/), licensed [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

 Open Notifications and click **Test toast** to try a sample. DND changes in preview mode do not overwrite the live setting.

 To toggle DND from a keybinding, use `qs -p /path/to/borderline-qs ipc call notifications toggleDnd` (or target your usual Quickshell config).

 See [the notification plan](docs/notifications-plan.md) for upcoming work.

 ### Calendar

 Click the date or time on the right side of the bar to open the Calendar tab. Use the arrows to browse months and **Today** to jump back to the current month. Today is highlighted, and dates from adjacent months are dimmed.

 #### Google Calendar (optional)

 The agenda scrolls across months and groups events by day. It opens near today and loads at least 30 days back and 90 days ahead, rounded out to whole months. Scroll near either end or use **Earlier** and **Later** to load another three months. Clicking a date in the grid jumps the agenda there without filtering it. Days with events have a dot. Borderline combines the primary and checked calendars from all connected Google accounts without editing events or storing them on disk.

 1. In [Google Cloud Console](https://console.cloud.google.com/), create a project and enable the **Google Calendar API**.
 2. Configure the OAuth consent screen. If the app is in **Testing**, add every Google account you want to connect as a test user. Google expires refresh tokens after seven days for external apps in Testing.
 3. Create an OAuth client of type **Desktop app**. Download its JSON and save it as `~/.local/share/borderline-qs/google-calendar-client.json` (under `$XDG_DATA_HOME` if set). Set its permissions to `600` and do not commit it.
 4. Install Python 3 and `xdg-open` if needed. Reopen the Calendar tab, click **Connect Google Calendar**, and grant both read-only permissions in your browser.

 Click **Add account** to sign in with another Google account using the same OAuth client. To remove just one account, select it in the dropdown and click **Disconnect**. Refresh tokens are stored next to the client JSON in `google-calendar-token.json`, with permissions `600`. To revoke an account's grant on Google's side, remove the connection in that [Google Account](https://myaccount.google.com/connections).

 ### Network controls

 Click the network icon to open the Network tab. Connect or disconnect Ethernet adapters, or turn Wi-Fi on or off and join, disconnect, or forget Wi-Fi networks. The page supports joining open and WPA-Personal networks. Enterprise profiles need to be configured separately before connecting.

 Network controls use Quickshell's NetworkManager backend. Connected adapters and networks show their IP addresses, gateways, and DNS servers inline. These fields use `nmcli`, usually included with NetworkManager.

 ### Bluetooth controls

 Click the Bluetooth icon to open the Bluetooth tab. Turn the default adapter on or off and connect or disconnect paired devices. **Pair new device…** opens `blueman-manager` for discovery and pairing.

 On Arch, install Blueman with `sudo pacman -S blueman`. If the manager reports that its applet is not running, start `blueman-applet` in your session. Blueman is optional for the tab’s paired-device controls.

 ### External monitor brightness

 Install `ddcutil` and enable DDC/CI in the monitor's settings. The brightness worker defaults to `ddcutil` display 1. To target a specific monitor, set `DDC_MONITOR_SERIAL` in the environment that launches Quickshell (not in the keybind).

 Bind `scripts/monitor-brightness up` and `scripts/monitor-brightness down` in Hyprland using the script's absolute path. The OSD shows the requested level immediately. Run `scripts/monitor-brightness show` to read the actual level and preview the OSD without changing brightness.

 ### Customization

 - Settings/Settings.qml: bar dimensions, UI scale, icon size, and clock format
 - Theme/Theme.qml: color palette


