# Borderline notifications plan

## Direction

Build a native QML notification center and toast stack on top of Quickshell's `NotificationServer`. Quickshell implements the freedesktop protocol; Borderline owns presentation and policy. Do not add a separate daemon or a SwayNC bridge.

- [Hokum](https://github.com/anomalyco/hokum): borrow the compact cards, animated restacking, hover pause, progress updates, and demo fixtures.
- [SwayNC](https://github.com/ErikReider/SwayNotificationCenter): borrow the collapsible inbox groups, clear controls, keyboard navigation, and persistent DND. Per-app rules and screen-sharing inhibitors are references for later.

## State and ownership

- One `NotificationService` at shell scope in `shell.qml`, outside the per-screen `Variants` in `Bar/Bar.qml`. Every bar and control center uses the same service.
- Use Quickshell's tracked notification objects as the source of truth for live items and app actions. An app-driven close removes the live item from all views. An application replacing an existing notification updates it in place without incrementing the count.
- Toast visibility is separate from the live inbox. Hiding a toast does not dismiss the notification. Transient items can appear as toasts but do not enter the inbox or any future history.
- Grouping is a view over the inbox, not notification identity. Two messages from one app are still independent. The bell badge counts live inbox items, not unread messages or groups.
- Keep volume and brightness feedback in the existing `BarOsd`.

## Milestones

### 1. Shared service and flat inbox

Implemented. Preview and live delivery, replacement, dismissal, and action invocation were smoke-tested on an isolated D-Bus session. Borderline now owns the notification bus on the live desktop.

- Add a bell in `Bar/BarWindow.qml` that opens a Notifications tab in the existing control center. Provide a list, empty state, count, individual dismiss, and clear-all.
- Render app name, icon, summary, body, and app actions. Start with plain text and advertise only the capabilities the UI supports.
- Add preview fixtures for a burst from one app, a long message, and a progress update. Preview mode must not instantiate the notification server or claim the D-Bus name.
- For live tests, first release `org.freedesktop.Notifications` from Noctalia, which owned it when this plan was written. Confirm that Borderline is the only owner before testing with `notify-send`.

### 2. Toasts and DND

Implemented. Preview and isolated live tests covered the three-toast limit, timeout without inbox dismissal, transient delivery, DND suppression without replay, and DND persistence across a process restart.

- Reuse the card content in a compact toast. Show up to three on a single monitor. Pause the timer on hover and animate the remaining cards when one leaves. Overflow still goes to the inbox unless the item is transient.
- Replace the Noctalia DND calls in `ControlCenter/QuickSettings.qml` with the service's shared DND flag. Persist the flag across restarts.
- Turning on DND hides existing toasts and suppresses new ones without dropping inbox items. Turning it off does not replay missed toasts. No critical bypass initially.
- Restored live objects from a Quickshell config reload should not appear as new toasts.

### 3. App groups and attachments

Implemented collapsible app groups and attachment thumbnails in the shared inbox/toast card. Tested group expansion, individual dismissal, local image paths, embedded image data, and missing-image fallback.

- Prefer `desktopEntry`, fall back to `appName`, and keep unidentified senders separate. Order groups by newest notification arrival.
- Show a single item as a card. Collapse larger groups to the newest preview and item count. Expanding a group reveals each card and its own actions. Clear group is available only while a group is expanded.
- Verify standard notification replacement first. The flat inbox already renders a numeric `value` hint as progress. Consider private stack-tag support later if real apps need it.

### 4. Keybindings and follow-ups

- `toggleDnd` and `clearAll` are available via Quickshell IPC. Right-click a toast to hide it without dismissing its inbox card. No dismiss-latest keybinding.
- Notification sounds are implemented: opt-in global toggle, test button, bundled fallback chime, and freedesktop sound hints. No per-app overrides.
- Defer unread state, per-app rules, critical bypass, inline replies, and screen-sharing inhibitors until daily use shows a need.

## Persistence decision

**V1 persists DND and the sound preference, not notifications.** The live inbox is session-only. A Quickshell config reload can carry live notifications forward, but a process restart or reboot starts with an empty inbox.

If reboot history turns out to be useful, add it as an opt-in local archive, separate from the live inbox. Store only display data such as sender, timestamp, summary, and body. Cap it by age and count, provide a clear-history control, and never save transient notifications. Restored entries are read-only: no old action buttons, no replayed popups, and no contribution to the live badge. Notification bodies can contain private messages and codes, so leave disk storage off by default.

## Checks before polishing

- One delivery produces one inbox item and at most one toast, even with two monitors.
- A standard replacement updates one item instead of making a duplicate. An app-driven close removes its item and any toast.
- An action on a live card still works after the toast disappears.
- DND suppresses popups without suppressing inbox delivery. Turning it off does not replay missed notifications.
- Transient items never appear in the inbox. Dismissing an item in an app group leaves the others intact.
- DND survives a full restart, while v1 inbox entries do not. A config reload does not replay old toasts.
