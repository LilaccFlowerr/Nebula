# Nebula

This is my hyprland setup, currently working on it on fedora :3

## What's in here

- `hypr/` Hyprland config, in Lua. `hyprland.lua` loads everything in `hypr/hyprland/`
- `quickshell/nebula/` the bar and (later) widgets, popups, lockscreen
- `matugen/` templates that turn the wallpaper into colors for Hyprland, Ghostty, VS Code and Quickshell
- `ghostty/` terminal config
- `design/` Figma stuff, not installed anywhere

Each folder gets symlinked into `~/.config`.

## Setup

On Fedora:

```bash
sudo dnf install hyprland hypridle hyprlock quickshell matugen swaybg fuzzel cliphist wl-clipboard \
    grim slurp mate-polkit playerctl brightnessctl cava zenity libnotify ffmpeg-free \
    papirus-icon-theme rsms-inter-fonts
```

The screen recorder uses gpu-screen-recorder from Flathub:

```bash
flatpak install flathub com.dec05eba.gpu_screen_recorder
```

Ghostty comes from the `scottames/ghostty` COPR. For icons I use Material Symbols Rounded
and Symbols Nerd Font (both from GitHub, dropped in `~/.local/share/fonts`). App icons come
from Papirus, the default GNOME ones show up as black squares in Quickshell.

```bash
git clone git@github.com:LilaccFlowerr/Nebula.git ~/setup/dotfiles
cd ~/setup/dotfiles
for dir in hypr quickshell matugen ghostty; do ln -s "$PWD/$dir" ~/.config/$dir; done
matugen image path/to/wallpaper.jpg
```

If something already exists in `~/.config` (Hyprland makes its own config on first
start), move it out of the way first. Then log out and pick Hyprland on the login screen.

Tap Super to open the launcher.

## Todo

- now playing widget on the desktop
- settings window, calendar and tray popups
- my own lockscreen instead of hyprlock
- wallpaper picker

## Inspired by

[Caelestia](https://github.com/caelestia-dots/shell),
[end-4](https://github.com/end-4/dots-hyprland),
[DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell)
and a lot of scrolling through r/unixporn.
