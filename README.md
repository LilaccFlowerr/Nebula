# Nebula

My Hyprland setup on Fedora, with a bar and widgets I'm writing myself in Quickshell.
Colors come from the wallpaper through matugen, so everything changes along with it.

Still very much a work in progress. The bar works (workspaces, window title, clock,
battery ring), the rest is coming.

## What's in here

- `hypr/` Hyprland config, in Lua. `hyprland.lua` loads everything in `hypr/hyprland/`
- `quickshell/` the bar and (later) widgets, popups, lockscreen
- `matugen/` templates that turn the wallpaper into colors for Hyprland, Ghostty, VS Code and Quickshell
- `ghostty/` terminal config
- `design/` Figma stuff, not installed anywhere

Each folder gets symlinked into `~/.config`.

## Setup

On Fedora:

```bash
sudo dnf install hyprland quickshell matugen fuzzel mako swaybg cliphist mate-polkit playerctl brightnessctl rsms-inter-fonts
```

Ghostty comes from the `scottames/ghostty` COPR. For icons I use Material Symbols Rounded
and Symbols Nerd Font (both from GitHub, dropped in `~/.local/share/fonts`).

```bash
git clone git@github.com:LilaccFlowerr/Nebula.git ~/setup/dotfiles
cd ~/setup/dotfiles
for dir in hypr quickshell matugen ghostty; do ln -s "$PWD/$dir" ~/.config/$dir; done
matugen image path/to/wallpaper.jpg
```

If something already exists in `~/.config` (Hyprland makes its own config on first
start), move it out of the way first. Then log out and pick Hyprland on the login screen.

## Todo

- now playing widget on the desktop
- music + visualizer in the middle of the bar
- quick settings, power menu, calendar
- my own notifications, launcher and lockscreen instead of mako, fuzzel and hyprlock

## Inspired by

[Caelestia](https://github.com/caelestia-dots/shell),
[end-4](https://github.com/end-4/dots-hyprland),
[DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell)
and a lot of scrolling through r/unixporn.
