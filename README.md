# dotfiles

My personal Linux desktop, built from scratch: **Hyprland** + a custom shell written
in **Quickshell (QML)**, styled after **Material 3 / Material You**.

> 🚧 Work in progress: currently in the design phase.

## Stack

| Part | Tool |
|---|---|
| Distro | Fedora |
| Compositor | [Hyprland](https://hyprland.org) |
| Shell (bar, widgets, popups) | [Quickshell](https://quickshell.org), custom QML |
| Colors | [matugen](https://github.com/InioX/matugen) (Material You from wallpaper) |
| Terminal | kitty |
| Dotfile management | [GNU Stow](https://www.gnu.org/software/stow/) |

## Planned features

- [ ] Hyprland base config: keybinds, blur, rounded corners, animations
- [ ] Material 3 theme with wallpaper-based colors
- [ ] Custom Quickshell bar
- [ ] **Now playing** desktop widget: album art, track info and controls (MPRIS)
- [ ] Notifications, launcher, lockscreen and OSDs in Quickshell

## Structure

Every top-level folder is a stow package that mirrors `$HOME`:

```
hypr/         → ~/.config/hypr
quickshell/   → ~/.config/quickshell
matugen/      → ~/.config/matugen
kitty/        → ~/.config/kitty
design/       # moodboard and Figma references (not installed)
```

## Installation

> ⚠️ Not usable yet. These steps are for when the configs exist.

```bash
# dependencies (Fedora)
sudo dnf install hyprland kitty stow
# Quickshell and matugen: see their docs for Fedora/COPR packages

# clone and link
git clone <this-repo> ~/Personal/dotfiles
cd ~/Personal/dotfiles
stow -t ~ hypr quickshell matugen kitty
```

Log out and pick **Hyprland** via the gear icon on the login screen.

To remove the symlinks again: `stow -D -t ~ hypr quickshell matugen kitty`

## Inspiration

- [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell)
- [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)
- [Caelestia](https://github.com/caelestia-dots/shell)
- [r/unixporn](https://reddit.com/r/unixporn)
