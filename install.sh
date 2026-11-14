#!/usr/bin/env bash
set -e

dir=$(cd "$(dirname "$0")" && pwd)
stamp=$(date +%Y%m%d-%H%M%S)

packages=(
    hyprland hypridle hyprlock quickshell matugen xdg-desktop-portal-hyprland
    ghostty firefox nautilus fuzzel cliphist wl-clipboard grim slurp mate-polkit
    playerctl brightnessctl cava zenity libnotify ffmpeg jq pciutils fastfetch
    gpu-screen-recorder inter-font ttf-material-symbols-variable
    ttf-nerd-fonts-symbols ttf-jetbrains-mono-nerd noto-fonts-emoji papirus-icon-theme
    git cmake ninja gcc qt6-shadertools pipewire wireplumber
)

log() { printf '\e[1;35m::\e[0m %s\n' "$*"; }
die() { printf '\e[1;31m::\e[0m %s\n' "$*" >&2; exit 1; }

copy() {
    local dest=~/.config/$1
    if [[ -e $dest && $updating == no ]]; then
        mv "$dest" "$dest.bak-$stamp"
        log "moved your old ~/.config/$1 to $1.bak-$stamp"
    fi
    mkdir -p "$dest"
    cp -rL "$dir/$1/." "$dest/"
}

printf '\n  \e[1;35mnebula\e[0m\n\n'

[[ $EUID != 0 ]] || die "don't run this with sudo, it asks when it needs to"
command -v pacman >/dev/null || die "this only works on arch (or something based on it)"

if [[ -d ~/.config/quickshell/nebula ]]; then
    updating=yes
    log "nebula is already installed, this will update it"
else
    updating=no
    log "this replaces your hypr, matugen and ghostty configs"
    log "the old ones get renamed to .bak, so nothing is lost"
fi
read -rp ":: go? [y/N] " answer
[[ $answer == [yY]* ]] || exit 0

log "installing packages (pacman asks first)"
sudo pacman -Syu --needed "${packages[@]}"

qt=$(pacman -Q qt6-base)
if [[ $(cat ~/.cache/nebula/m3shapes 2>/dev/null) != "$qt" ]]; then
    log "building m3shapes, this takes a minute"
    tmp=$(mktemp -d)
    git clone -q --depth 1 https://github.com/soramanew/m3shapes.git "$tmp"
    cmake -S "$tmp" -B "$tmp/build" -G Ninja -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib >/dev/null
    cmake --build "$tmp/build"
    sudo cmake --install "$tmp/build" >/dev/null
    rm -rf "$tmp"
    mkdir -p ~/.cache/nebula
    echo "$qt" > ~/.cache/nebula/m3shapes
fi

log "copying configs"
copy hypr
copy quickshell/nebula
copy matugen
copy ghostty

if [[ ! -s ~/.local/state/nebula/colors.json ]]; then
    log "making colors from the default wallpaper"
    mkdir -p ~/.local/state/nebula ~/.cache/wal ~/.config/ghostty/themes
    matugen image ~/.config/quickshell/nebula/assets/default.jpg
fi

echo
if [[ $updating == yes ]]; then
    echo "done! restart quickshell (or log out and back in) to see the changes."
else
    echo "done! log out and pick hyprland on the login screen."
    echo "tap super for the launcher, super+t for a terminal."
fi
echo
