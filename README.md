
# Borderline-qs

 │ Borderline-qs is a small, floating status bar for Hyprland, built with Quickshell and inspired by Apple’s Dynamic Island. I built it for my own desktop. For now, it’s just a bar.

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

 ### External monitor brightness

 Install `ddcutil` and enable DDC/CI in the monitor's settings. The brightness worker defaults to `ddcutil` display 1. To target a specific monitor, set `DDC_MONITOR_SERIAL` in the environment that launches Quickshell (not in the keybind).

 Bind `scripts/monitor-brightness up` and `scripts/monitor-brightness down` in Hyprland using the script's absolute path. The OSD shows the requested level immediately. Run `scripts/monitor-brightness show` to read the actual level and preview the OSD without changing brightness.

 ### Customization

 - Settings/Settings.qml: bar dimensions, UI scale, icon size, and clock format
 - Theme/Theme.qml: color palette


