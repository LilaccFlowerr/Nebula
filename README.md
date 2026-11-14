<h1 align="center">Nebula</h1>

<p align="center">
  A Hyprland desktop made from scratch, with a shell written in Quickshell.<br>
  Material 3 Expressive shapes everywhere, and colors that follow your wallpaper.<br>
  
  **If you like it consider leaving a star and joining the [discord](https://discord.gg/jwGwtg68qt)**
</p>

<p align="center">
  <img src="https://img.shields.io/github/last-commit/LilaccFlowerr/Nebula?style=for-the-badge&color=cba6f7&labelColor=1e1e2e" alt="last commit">
  <img src="https://img.shields.io/github/stars/LilaccFlowerr/Nebula?style=for-the-badge&color=f5c2e7&labelColor=1e1e2e" alt="stars">
  <img src="https://img.shields.io/github/license/LilaccFlowerr/Nebula?style=for-the-badge&color=89b4fa&labelColor=1e1e2e" alt="license">
</p>

https://github.com/user-attachments/assets/b3be7c33-a358-43e6-9ec0-5404f7068d17


## Features

**Bar.** Three floating islands, each its own purpose, left shows your workspaces, middle shows the apps youve pinned or are running and right is the powermenu, settings menu and the other system stuff :D

**Equalizer.** An equalizer built into the shell, which starts its own pipewire service! press super + shift + n to open the media player, and then you can press EQ for the equalizer

**Lockscreen.** A lockscreen with a black hole music player and orbiting planets.

**Launcher.** Super opens the launcher, from this launcher you can do quick actions with > for wallpapers, theme etc.

**Desktop widgets.** Theres various widgets and desktop things to choose from, try them out id say!!

**Wallpapers and themes.** A wallpaper picker AND theme picker!

**Notifications.** A nebula cloud with all your notifications. press Super + N 

**Quick settings and Settings.** Quick settings for wifi bluetooth and all the sorts, bigger settings for configuring your desktop, this can also be done from `~/.config/nebula/settings.json`

## Installation

Nebula is an OS made for arch, and depends on pacman this shell does not have official support on other distros.

### Install

```bash
sudo pacman -Syu --needed git
git clone https://github.com/LilaccFlowerr/Nebula.git
cd Nebula
./install.sh
```

It copies the configs into `~/.config`. Whatever was there gets renamed to `.bak-<date>`, so
nothing is lost. Your own tweaks go in `~/.config/nebula/` (`hypr-vars.lua`, `hypr-user.lua`,
`settings.json`): the installer never touches that folder.

### Tips

1. Tap **Super** for the launcher, **Super + T** opens a terminal. You can set these in settings
2. Click the gear in the top right, then **Settings**: set your wallpaper, monitors and
   keyboard layout there.
3. Put your own wallpapers in `~/Pictures/Wallpapers`.

<details>
<summary>Manual install (if you'd rather do every step yourself)</summary>

#### Packages

```bash
sudo pacman -S --needed hyprland hypridle hyprlock quickshell matugen xdg-desktop-portal-hyprland \
    ghostty firefox nautilus fuzzel cliphist wl-clipboard grim slurp mate-polkit playerctl \
    brightnessctl cava zenity libnotify ffmpeg jq pciutils fastfetch gpu-screen-recorder \
    inter-font ttf-material-symbols-variable ttf-nerd-fonts-symbols ttf-jetbrains-mono-nerd \
    noto-fonts-emoji papirus-icon-theme pipewire wireplumber git cmake ninja gcc qt6-shadertools
```

- Desktop: `hyprland` `hypridle` `hyprlock` `quickshell` `matugen` `xdg-desktop-portal-hyprland`
- Apps: `ghostty` `firefox` `nautilus` (just the defaults, change them in Settings > Apps)
- Tools: `fuzzel` (only for the clipboard picker) `cliphist` `wl-clipboard` `grim` `slurp`
  `mate-polkit` `playerctl` `brightnessctl` `cava` `zenity` `libnotify` `ffmpeg` `jq` `pciutils`
  `fastfetch`
- Sound and the equalizer: `pipewire` `wireplumber`
- Screen recorder: `gpu-screen-recorder`
- Fonts: `inter-font` `ttf-material-symbols-variable` `ttf-nerd-fonts-symbols`
  `ttf-jetbrains-mono-nerd` `noto-fonts-emoji`
- Icons: `papirus-icon-theme`. Quickshell uses it on its own (some GNOME icons render as black
  squares otherwise).
- To build m3shapes: `git` `cmake` `ninja` `gcc` `qt6-shadertools`

#### m3shapes

All the shapes and the morphing between them come from
[m3shapes](https://github.com/soramanew/m3shapes), a QML port of Google's Material 3 shapes.

```bash
git clone https://github.com/soramanew/m3shapes ~/others/m3shapes
cmake -S ~/others/m3shapes -B ~/others/m3shapes/build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib
ninja -C ~/others/m3shapes/build
sudo ninja -C ~/others/m3shapes/build install
```

#### Nebula

Clone the repo and copy the folders into `~/.config`. If something is already there
(Hyprland makes its own config on first start), move it out of the way first.

```bash
git clone https://github.com/LilaccFlowerr/Nebula.git
cd Nebula
mkdir -p ~/.config/quickshell
cp -rL hypr matugen ghostty ~/.config/
cp -rL quickshell/nebula ~/.config/quickshell/
mkdir -p ~/.local/state/nebula ~/.cache/wal ~/.config/ghostty/themes
matugen image ~/.config/quickshell/nebula/assets/default.jpg
```

</details>

## Usage

### Keybinds

- `Super` (tap) launcher
- `Super + T` terminal, `Super + W` browser, `Super + E` files, `Super + C` editor
- `Super + Q` close, `Super + F` fullscreen, `Super + V` float
- `Super + 1-0` go to workspace, `Super + Shift + 1-0` move window there
- `Super + Left/Right` previous/next workspace, `Super + Ctrl + arrows` move focus
- `Super + S` scratchpad, `Super + Alt + S` move window to the scratchpad
- `Super + N` missed notifications 
- `Super + Shift + N` media player
- `Super + Shift + S` screenshot a region, `Print` the whole screen
- `Super + Shift + R` record the screen, `Super + Shift + Alt + R` record a region
- `Super + Shift + V` clipboard history
- `Super + Shift + E` edit your desktop widgets
- `Super + L` lock, `Super + M` log out

### Launcher commands

Type `>` in the launcher to see them, or `>` followed by a few letters to filter.

- `>theme` opens a picker with the eight color schemes in the ring
- `>wallpaper` opens a picker with your wallpapers in the ring
- `>settings` opens the settings window
- `>lock` locks the screen
- `>sleep` suspends
- `>restart` reboots
- `>shutdown` powers off
- `>log out` ends your session
- `>record` starts a screen recording
- `>dark mode` or `>light mode` switches between dark and light (it shows whichever you're not in)

### IPC

Everything can be opened from a script or your own keybinds:

```bash
qs -c nebula ipc call <target> <function>
```

Targets: `launcher`, `settings`, `quicksettings`, `media`, `missed`, `calendar`, `tray`, `system`,
`recorder`, `screenshot`, `wallpaper`, `scheme`, `lock`, `widgets`. Run `qs -c nebula ipc show` for the full list.

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
cd Nebula && git pull && ./install.sh
```

It copies the new configs over the old ones (no backups this time) and keeps your colors and
everything in `~/.config/nebula/`. It also rebuilds m3shapes when Qt was updated, otherwise
the bar may not show up.

Installed by hand? Rebuild it in the folder you cloned it to:

```bash
cd ~/others/m3shapes && git pull && ninja -C build && sudo ninja -C build install
```

## Roadmap

- [x] Lock screen
- [x] Widget edit mode: snapping, resizing, undo, layouts
- [x] Lyrics widget
- [ ] Visualizer widget
- [ ] Make the other widgets prettier

## Credits

Inspired by [Caelestia](https://github.com/caelestia-dots/shell),
[end-4](https://github.com/end-4/dots-hyprland),
[DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell)
[Serpantinum](https://github.com/ilyamiro/serpantinum)
and a lot of scrolling through r/unixporn. Shapes by
[m3shapes](https://github.com/soramanew/m3shapes). The loading animation is borrowed (with
permission) from [dynbar](https://github.com/leithXD/dynbar).

Want to help? See [CONTRIBUTING.md](CONTRIBUTING.md). Licensed under the AGPL-3.0, see [LICENSE](LICENSE).


## Stonks 📈

<a href="https://star-history.com/#LilaccFlowerr/Nebula&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=LilaccFlowerr/nebula&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=LilaccFlowerr/nebula&type=Date" />
    <img alt="Star history chart" src="https://api.star-history.com/svg?repos=LilaccFlowerr/nebula&type=Date" />
  </picture>
</a>
