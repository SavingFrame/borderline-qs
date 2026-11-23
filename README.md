
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

 ### Network controls

 Click the network icon to open the Network tab. Connect or disconnect Ethernet adapters, or turn Wi-Fi on or off and join, disconnect, or forget Wi-Fi networks. The page supports joining open and WPA-Personal networks. Enterprise profiles need to be configured separately before connecting.

 Network controls use Quickshell's NetworkManager backend. Connected adapters and networks show their IP addresses, gateways, and DNS servers inline. These fields use `nmcli`, usually included with NetworkManager.

 ### External monitor brightness

 Install `ddcutil` and enable DDC/CI in the monitor's settings. The brightness worker defaults to `ddcutil` display 1. To target a specific monitor, set `DDC_MONITOR_SERIAL` in the environment that launches Quickshell (not in the keybind).

 Bind `scripts/monitor-brightness up` and `scripts/monitor-brightness down` in Hyprland using the script's absolute path. The OSD shows the requested level immediately. Run `scripts/monitor-brightness show` to read the actual level and preview the OSD without changing brightness.

 ### Customization

 - Settings/Settings.qml: bar dimensions, UI scale, icon size, and clock format
 - Theme/Theme.qml: color palette


