# Project instructions

After modifying the Quickshell configuration, copy the changed files from this checkout to `~/.config/quickshell/borderline-qs/`, preserving their relative paths. This is the installed copy that Quickshell uses. Copy only the files changed for the task so unrelated local configuration is preserved.

For example, from the repository root:

```sh
rsync -aR Bar/BarWindow.qml Bar/Widgets/ClockWidget.qml ~/.config/quickshell/borderline-qs/
```
