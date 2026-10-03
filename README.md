# Nebula

My own Hyprland desktop on Fedora, built from scratch :3

Almost everything on screen is made in Quickshell: the bar, the launcher, notifications,
the wallpaper. The colors come from the wallpaper through matugen, so if you pick a new
wallpaper the whole desktop changes color with it, no restart needed.

## What it does

- A bar made of three floating islands. The middle one works like the iPhone's dynamic
  island. It shows the window you're on or the song that's playing, and it pops open for
  volume, brightness, notifications and battery stuff. Click it while music plays and it
  turns into a bigger player with synced lyrics.
- Quick settings under the gear: wifi, bluetooth, do not disturb, volume and brightness.
- A launcher that opens when you tap Super. Your apps sit in a ring around a big flower
  shape. Type `>` for commands, or `>wallpaper` to pick a wallpaper.
- A screen recorder hiding in the bottom right corner (or Super+Shift+R).

## What's in here

- `hypr/` Hyprland config, in Lua. `hyprland.lua` loads everything in `hypr/hyprland/`
- `quickshell/nebula/` the shell itself
- `matugen/` templates that turn the wallpaper into colors for Hyprland, Ghostty, VS Code and Quickshell
- `ghostty/` terminal config
- `design/` Figma stuff, not installed anywhere

Each folder gets symlinked into `~/.config`.

## Setup

On Fedora:

```bash
sudo dnf install hyprland hypridle hyprlock quickshell matugen fuzzel cliphist wl-clipboard \
    grim slurp mate-polkit playerctl brightnessctl cava zenity libnotify ffmpeg-free \
    papirus-icon-theme rsms-inter-fonts
```

fuzzel is only there for the clipboard history (Super+Shift+V), until I make my own.

The screen recorder uses gpu-screen-recorder from Flathub:

```bash
flatpak install flathub com.dec05eba.gpu_screen_recorder
```

Ghostty comes from the `scottames/ghostty` COPR. For icons I use Material Symbols Rounded
and Symbols Nerd Font (both from GitHub, dropped in `~/.local/share/fonts`). App icons come
from Papirus, because the default GNOME ones show up as black squares in Quickshell.

```bash
git clone git@github.com:LilaccFlowerr/Nebula.git ~/setup/dotfiles
cd ~/setup/dotfiles
for dir in hypr quickshell matugen ghostty; do ln -s "$PWD/$dir" ~/.config/$dir; done
matugen image path/to/wallpaper.jpg
```

If something already exists in `~/.config` (Hyprland makes its own config on first
start), move it out of the way first. Then log out and pick Hyprland on the login screen.
After that, put your wallpapers in `~/Pictures/Wallpapers` and switch between them with
`>wallpaper` in the launcher.

## Todo

- now playing widget on the desktop
- settings window
- calendar and tray popups
- my own lockscreen and polkit prompt

## Inspired by

[Caelestia](https://github.com/caelestia-dots/shell),
[end-4](https://github.com/end-4/dots-hyprland),
[DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell)
and a lot of scrolling through r/unixporn.
