# Nebula

My own Hyprland desktop, built from scratch :3

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

Made on Arch (EndeavourOS). Everything below is in the official repos except m3shapes,
which you build yourself.

Dependencies:

- Desktop: `hyprland` `hypridle` `hyprlock` `quickshell` `matugen` `xdg-desktop-portal-hyprland`
- Apps: `ghostty` `firefox` `nautilus` (the defaults, you can change them in Settings > Apps)
- Tools: `fuzzel` `cliphist` `wl-clipboard` `grim` `slurp` `mate-polkit` `playerctl`
  `brightnessctl` `cava` `zenity` `libnotify` `ffmpeg` `jq` `pciutils`
- Screen recorder: `gpu-screen-recorder`
- Fonts: `inter-font` `ttf-material-symbols-variable` `ttf-nerd-fonts-symbols` `noto-fonts-emoji`
- Icons: `papirus-icon-theme`
- To build m3shapes: `git` `cmake` `ninja` `gcc` `qt6-shadertools`

```bash
sudo pacman -S hyprland hypridle hyprlock quickshell matugen xdg-desktop-portal-hyprland \
    ghostty firefox nautilus fuzzel cliphist wl-clipboard grim slurp mate-polkit playerctl \
    brightnessctl cava zenity libnotify ffmpeg jq pciutils gpu-screen-recorder inter-font \
    ttf-material-symbols-variable ttf-nerd-fonts-symbols noto-fonts-emoji papirus-icon-theme \
    git cmake ninja gcc qt6-shadertools
```

fuzzel is only there for the clipboard history (Super+Shift+V), until I make my own.

All the shapes (the cookies, the launcher flower and the morphing between them) come from
[m3shapes](https://github.com/soramanew/m3shapes), a QML port of Google's Material 3
shapes. It's not packaged, so you build it yourself:

```bash
git clone https://github.com/soramanew/m3shapes ~/others/m3shapes
cmake -S ~/others/m3shapes -B ~/others/m3shapes/build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
ninja -C ~/others/m3shapes/build
sudo ninja -C ~/others/m3shapes/build install
```

If the bar doesn't show up after a Qt update, rebuild it (`git pull`, then the last two lines again).

App icons come from Papirus, and it's part of the look: Quickshell uses it on its own, and
the default GNOME ones show up as black squares there. For your file manager and other GTK
apps you pick it yourself, so they match too.

Then link the folders and generate the colors once:

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

Monitors: only a fallback is set (preferred mode, placed automatically, scale 1). Set your own
resolution, refresh rate and scale in Settings > System > Displays, or add an `hl.monitor`
block in `hypr/hyprland.lua`.

## Making it yours

Don't edit the files in `hypr/` to change things, they're in git. On first start two empty
files are made in `~/.config/nebula/`:

- `hypr-vars.lua` returns a table that overrides the defaults in `hypr/variables.lua`:
  apps, gaps, rounding, opacity, blur, keyboard layout and every keybind (`kbTerminal` and
  so on, a string or a list of keys).
- `hypr-user.lua` is loaded last, for your own binds, window rules, monitors and autostart.

The shell settings live in `~/.config/nebula/settings.json`, which the Settings window
writes for you.

## Todo

- settings window
- calendar and tray popups
- my own lockscreen and polkit prompt

## Inspired by

[Caelestia](https://github.com/caelestia-dots/shell),
[end-4](https://github.com/end-4/dots-hyprland),
[DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell)
and a lot of scrolling through r/unixporn. The loading animation is borrowed (with permission) from
[dynbar](https://github.com/leithXD/dynbar).
