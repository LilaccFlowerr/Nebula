<h1 align="center">Nebula</h1>

<p align="center">
  A Hyprland desktop made from scratch, with a shell written in Quickshell.<br>
  Material 3 Expressive shapes everywhere, and colors that follow your wallpaper.
</p>

<p align="center">
  <img src="https://img.shields.io/github/last-commit/LilaccFlowerr/Nebula?style=for-the-badge&color=cba6f7&labelColor=1e1e2e" alt="last commit">
  <img src="https://img.shields.io/github/stars/LilaccFlowerr/Nebula?style=for-the-badge&color=f5c2e7&labelColor=1e1e2e" alt="stars">
  <img src="https://img.shields.io/github/license/LilaccFlowerr/Nebula?style=for-the-badge&color=89b4fa&labelColor=1e1e2e" alt="license">
</p>

<!-- Drag the showcase video into a GitHub comment box, copy the user-attachments link it gives you and put it here: -->
https://github.com/user-attachments/assets/b3be7c33-a358-43e6-9ec0-5404f7068d17

Nebula is my own desktop. Not a fork of someone else's dots, I built it piece by piece
because I wanted something that feels alive: shapes that morph into each other, a bar that
reacts to what you're doing, and a wallpaper that recolors the whole thing the moment you
pick it. No reloads, no config files to touch unless you want to. Everything has a setting.

## Features

**Bar.** Three floating islands. Workspaces and your OS logo on the left, the clock, tray,
quick settings and power menu on the right. In between sits a glass media island with the
song that's playing, a wavy progress line and a visualizer. Click it and it grows into a
full player with synced lyrics.

**Launcher.** Tap Super. Your apps sit in a ring around a big clover, each in its own shape.
Type to search, `>` for commands (lock, sleep, record, theme, wallpaper, ...).

**Desktop widgets.** Now playing, clock, weather, calendar, battery, images and notes, all
living on your wallpaper in a Material shape of your choice. Right click one to change its
shape, size, color and options. Save your layout as a preset and switch between them.

**Wallpapers and themes.** Pick a wallpaper and it grows in through a spinning shape (or a
glitch, or a fade), then matugen recolors the bar, widgets, Hyprland borders, Ghostty and
VS Code. Eight color schemes, light and dark.

**Notifications.** Glass cards that stack under the right island. Messages from the same
chat get grouped, hover to fan them out, swipe to dismiss. Do not disturb in quick settings.

**Quick settings and Settings.** Wifi, bluetooth, do not disturb, volume and brightness under
the gear. The Settings tile grows the panel into a full settings window: appearance, windows,
desktop, bar, wifi/ethernet/bluetooth, displays, power, input, default apps, notifications and
the recorder. There's search too (Ctrl+F).

**Little things.** Calendar and weather under the clock, volume and brightness OSD, a screen
recorder hiding in the bottom right corner, screenshots that keep your popups open, battery
notifications, and an About page.

## Installation

Nebula is made on Arch (EndeavourOS). Other distros can work, but you're on your own for
the package names.

### Guided install

```bash
sudo pacman -Syu --needed git
git clone https://github.com/LilaccFlowerr/Nebula.git ~/setup/dotfiles
cd ~/setup/dotfiles
./install.sh
```

The installer walks you through packages, building m3shapes, linking configs and generating
colors. Run it as your normal user; it asks for sudo when needed. Before installing,
it lists any configs it will replace and asks whether to back them up and continue.
Press Enter or choose No to cancel without changes. Existing `hypr`,
`quickshell`, `matugen` and `ghostty` configs are moved to a unique
`~/.config/nebula-backup-*` folder before linking. Keep the checkout where it is.

Use `./install.sh --dry-run` to preview the steps. You can run the installer again after
a failure; correct links and existing colors are kept. It does a full system package
upgrade and rebuilds m3shapes each time. It doesn't configure your login manager,
networking or audio services; start with a working Arch desktop.

When it's done, log out and choose Hyprland on the login screen.

### Manual install

If you'd rather do each step yourself, follow the instructions below.

### Dependencies

Everything is in the official repos except m3shapes, which you build yourself.

```bash
sudo pacman -S hyprland hypridle hyprlock quickshell matugen xdg-desktop-portal-hyprland \
    ghostty firefox nautilus fuzzel cliphist wl-clipboard grim slurp mate-polkit playerctl \
    brightnessctl cava zenity libnotify ffmpeg jq pciutils gpu-screen-recorder inter-font \
    ttf-material-symbols-variable ttf-nerd-fonts-symbols noto-fonts-emoji papirus-icon-theme \
    git cmake ninja gcc qt6-shadertools
```

<details>
<summary>What each package is for</summary>

- Desktop: `hyprland` `hypridle` `hyprlock` `quickshell` `matugen` `xdg-desktop-portal-hyprland`
- Apps: `ghostty` `firefox` `nautilus` (just the defaults, change them in Settings > Apps)
- Tools: `fuzzel` (only for the clipboard picker) `cliphist` `wl-clipboard` `grim` `slurp`
  `mate-polkit` `playerctl` `brightnessctl` `cava` `zenity` `libnotify` `ffmpeg` `jq` `pciutils`
- Screen recorder: `gpu-screen-recorder`
- Fonts: `inter-font` `ttf-material-symbols-variable` `ttf-nerd-fonts-symbols` `noto-fonts-emoji`
- Icons: `papirus-icon-theme`. Quickshell uses it on its own (some GNOME icons render as black
  squares otherwise). Pick it for your GTK apps too so everything matches.
- To build m3shapes: `git` `cmake` `ninja` `gcc` `qt6-shadertools`

</details>

### m3shapes

All the shapes and the morphing between them come from
[m3shapes](https://github.com/soramanew/m3shapes), a QML port of Google's Material 3 shapes.

```bash
git clone https://github.com/soramanew/m3shapes ~/others/m3shapes
cmake -S ~/others/m3shapes -B ~/others/m3shapes/build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
ninja -C ~/others/m3shapes/build
sudo ninja -C ~/others/m3shapes/build install
```

### Nebula

Clone the repo and link the folders into `~/.config`. If something is already there
(Hyprland makes its own config on first start), move it out of the way first.

```bash
git clone https://github.com/LilaccFlowerr/Nebula.git ~/setup/dotfiles
cd ~/setup/dotfiles
for dir in hypr quickshell matugen ghostty; do ln -s "$PWD/$dir" ~/.config/$dir; done
matugen image quickshell/nebula/assets/default.jpg
```

Log out and pick Hyprland on the login screen. The shell starts on its own. Put your own wallpapers in `~/Pictures/Wallpapers` and pick one in
Settings > Appearance or with `>wallpaper` in the launcher.

## Usage

### Keybinds

- `Super` (tap) launcher
- `Super + T` terminal, `Super + W` browser, `Super + E` files, `Super + C` editor
- `Super + Q` close, `Super + F` fullscreen, `Super + V` float
- `Super + 1-0` go to workspace, `Super + Shift + 1-0` move window there
- `Super + Left/Right` previous/next workspace, `Super + Ctrl + arrows` move focus
- `Super + S` scratchpad, `Super + Alt + S` move window to the scratchpad
- `Super + N` media player
- `Super + Shift + S` screenshot a region, `Print` the whole screen
- `Super + Shift + R` record the screen, `Super + Shift + Alt + R` record a region
- `Super + Shift + V` clipboard history
- `Super + L` lock, `Super + M` log out

### Launcher commands

Type `>` in the launcher to see them. `>wallpaper` and `>theme` open a picker in the ring.

### IPC

Everything can be opened from a script or your own keybinds:

```bash
qs -c nebula ipc call <target> <function>
```

Targets: `launcher`, `settings`, `quicksettings`, `media`, `calendar`, `tray`, `system`,
`recorder`, `screenshot`, `wallpaper`, `scheme`. Run `qs -c nebula ipc show` for the full list.

## Configuring

Most things are in the Settings window (gear > Settings, or `>settings` in the launcher). It
writes `~/.config/nebula/settings.json`, which you can also edit by hand; changes show up
right away.

Don't edit the files in `hypr/` (they're in git and get overwritten when you update). On
first start two empty files are made in `~/.config/nebula/`:

- `hypr-vars.lua` returns a table that overrides the defaults in
  [`hypr/variables.lua`](hypr/variables.lua): apps, borders, shadow, keyboard layout and
  every keybind (`kbTerminal` and so on, a string or a list of keys).
- `hypr-user.lua` is loaded last, for your own binds, window rules, monitors and autostart.

```lua
-- ~/.config/nebula/hypr-vars.lua
return {
    kbLayout   = "us,nl",
    kbTerminal = { "SUPER + T", "SUPER + Return" },
}
```

Monitors only have a fallback (preferred mode, scale 1). Set yours in
Settings > System > Displays.

## Updating

```bash
cd ~/setup/dotfiles && git pull
```

The shell reloads by itself. After a Qt update the bar may not show up: rebuild m3shapes.

```bash
cd ~/others/m3shapes && git pull && ninja -C build && sudo ninja -C build install
```

## FAQ

**The bar doesn't show up.** Check the log with `qs log -c nebula`. Most of the time it's
m3shapes after a Qt update (see Updating).

**Notifications don't show.** Another notification daemon (like mako) took the spot. Kill it
and Nebula picks it up again. Flatpak apps may need
`flatpak override --user --talk-name=org.freedesktop.Notifications <app-id>`.

**Some app icons are black squares.** Install `papirus-icon-theme`.

## Credits

Inspired by [Caelestia](https://github.com/caelestia-dots/shell),
[end-4](https://github.com/end-4/dots-hyprland),
[DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell)
and a lot of scrolling through r/unixporn. Shapes by
[m3shapes](https://github.com/soramanew/m3shapes). The loading animation is borrowed (with
permission) from [dynbar](https://github.com/leithXD/dynbar).

MIT licensed, see [LICENSE](LICENSE).
