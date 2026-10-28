#!/usr/bin/env bash
set -Eeuo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
config_dir="$HOME/.config"
dry_run=false
backup_dir=
accent= reset= bold=
if [[ -t 1 && -z ${NO_COLOR+x} && ${TERM:-dumb} != dumb ]]; then
    accent=$'\033[38;5;183m' bold=$'\033[1m' reset=$'\033[0m'
fi

packages=(
    hyprland hypridle hyprlock quickshell matugen xdg-desktop-portal-hyprland
    ghostty firefox nautilus fuzzel cliphist wl-clipboard grim slurp mate-polkit
    playerctl brightnessctl cava zenity libnotify ffmpeg jq pciutils fastfetch
    gpu-screen-recorder inter-font ttf-material-symbols-variable
    ttf-nerd-fonts-symbols ttf-jetbrains-mono-nerd noto-fonts-emoji papirus-icon-theme
    git cmake ninja gcc qt6-shadertools
)

say() { printf '  %s\n' "$*"; }
step() { printf '\n%s%s  %s / 5  %s%s\n\n' "$bold" "$accent" "$1" "$2" "$reset"; }
fail() { printf '\n  %s\n' "$*" >&2; exit 1; }
confirm() {
    local answer
    printf '\n  %s [y/N] ' "$1"
    read -r answer || return 1
    [[ $answer == [yY] || $answer == [yY][eE][sS] ]]
}
run() {
    if "$dry_run"; then
        printf '    '
        printf '%q ' "$@"
        printf '\n'
    else
        "$@"
    fi
}
on_error() {
    local status=$?
    printf '\n  Installation stopped (exit %s). Fix the error above, then run ./install.sh again.\n' "$status" >&2
    [[ -z $backup_dir ]] || printf '  Your config backups are in %s\n' "$backup_dir" >&2
    exit "$status"
}

review_configs() {
    local name target
    local conflicts=()
    for name in hypr quickshell matugen ghostty; do
        target="$config_dir/$name"
        if [[ -L $target && $(readlink -f -- "$target") == "$repo_dir/$name" ]]; then
            continue
        fi
        if [[ -e $target || -L $target ]]; then
            conflicts+=("$target")
        fi
    done

    local question='Start installation?'
    if (( ${#conflicts[@]} )); then
        printf '\n%s%s  Existing configs found%s\n\n' "$bold" "$accent" "$reset"
        say 'Installing Nebula will replace these active configs:'
        for target in "${conflicts[@]}"; do
            say "  $target"
        done
        printf '\n'
        say 'Your current setup for these apps will be replaced by Nebula.'
        say "We'll move the originals to $config_dir/nebula-backup-* first."
        say 'You can restore them later. Other config folders will stay as they are.'
        question='Back up these configs and install Nebula?'
    fi
    if "$dry_run"; then
        say "$question [y/N] (preview)"
        return 0
    fi
    confirm "$question"
}

link_configs() {
    local name target source
    run mkdir -p -- "$config_dir"
    for name in hypr quickshell matugen ghostty; do
        source="$repo_dir/$name"
        target="$config_dir/$name"
        if [[ -L $target && $(readlink -f -- "$target") == "$source" ]]; then
            say "$name is already linked."
            continue
        fi
        if [[ -e $target || -L $target ]]; then
            if [[ -z $backup_dir ]]; then
                if "$dry_run"; then
                    backup_dir="$config_dir/nebula-backup-<unique-id>"
                else
                    backup_dir=$(mktemp -d "$config_dir/nebula-backup-XXXXXXXX")
                fi
            fi
            say "Backing up $target → $backup_dir/$name"
            run mv -T -- "$target" "$backup_dir/$name"
        fi
        run ln -sT -- "$source" "$target"
        say "Linked $name."
    done
}

main() {
    case ${1:-} in
        --dry-run) dry_run=true ;;
        -h|--help)
            printf 'Usage: ./install.sh [--dry-run]\n\nInstall Nebula on Arch Linux or EndeavourOS. Run as your normal user.\nUse --dry-run to preview commands without changing anything.\n'
            return ;;
        '') ;;
        *) fail "Unknown option: $1. Use --help for usage." ;;
    esac
    [[ $# -le 1 ]] || fail 'Use only one option. See --help.'
    trap on_error ERR

    printf '\n%s%s  Nebula%s\n' "$bold" "$accent" "$reset"
    say 'A few steps to your new desktop.'
    "$dry_run" && say 'Preview only — nothing will be changed.'

    step 1 'Check your system'
    [[ $EUID -ne 0 ]] || fail 'Run this as your normal user, without sudo. It will ask when needed.'
    [[ -r /etc/os-release ]] || fail 'Cannot identify this system.'
    local ID= ID_LIKE= name resolved
    # shellcheck source=/etc/os-release
    source /etc/os-release
    [[ $ID == arch || " ${ID_LIKE:-} " == *' arch '* ]] || fail 'This installer supports Arch Linux and Arch-based distributions only.'
    command -v pacman >/dev/null || fail 'pacman is required.'
    command -v sudo >/dev/null || fail 'Install sudo and configure it for your user first.'
    [[ ${XDG_CONFIG_HOME:-$HOME/.config} == "$HOME/.config" ]] || fail 'Nebula currently expects configs in ~/.config. A custom XDG_CONFIG_HOME is not supported.'
    for name in hypr quickshell matugen ghostty; do
        [[ -d $repo_dir/$name ]] || fail "Missing $name. Run this from a full Nebula checkout."
        resolved=$(realpath -m -- "$HOME/.config/$name")
        [[ $repo_dir != "$resolved" && $repo_dir != "$resolved/"* ]] || fail "Move this checkout outside ~/.config/$name before installing."
    done
    [[ -f $repo_dir/quickshell/nebula/assets/default.jpg ]] || fail 'The default wallpaper is missing.'
    say "Repository: $repo_dir"
    say 'This will update system packages, build M3Shapes and link four config folders:'
    say 'hypr, quickshell, matugen and ghostty → ~/.config'
    say 'Existing folders or links will be moved to a backup beside them.'
    say 'Keep this checkout in place: your configs will point to it.'
    if ! "$dry_run"; then
        [[ -t 0 ]] || fail 'Run ./install.sh in a terminal so you can review the prompts.'
    fi
    review_configs || { say 'Cancelled. Nothing changed.'; return; }

    step 2 'Install packages'
    say 'pacman will show the download and ask before installing.'
    run sudo pacman -Syu --needed "${packages[@]}"

    step 3 'Build the shapes'
    say 'Downloading M3Shapes from soramanew/m3shapes and building it for your Qt version.'
    local build_dir
    if "$dry_run"; then
        build_dir="$HOME/.cache/nebula/m3shapes-<unique-id>"
    else
        mkdir -p -- "$HOME/.cache/nebula"
        build_dir=$(mktemp -d "$HOME/.cache/nebula/m3shapes-XXXXXXXX")
    fi
    run git clone --depth 1 https://github.com/soramanew/m3shapes.git "$build_dir/source"
    run cmake -S "$build_dir/source" -B "$build_dir/build" -G Ninja \
        -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib
    run cmake --build "$build_dir/build" --parallel 2
    run sudo cmake --install "$build_dir/build"
    say "Build files: $build_dir"

    step 4 'Link your configs'
    link_configs

    step 5 'Prepare your colors'
    if [[ -s $HOME/.local/state/nebula/colors.json && -s $repo_dir/ghostty/themes/matugen ]]; then
        say 'Your existing colors are already set up. Keeping them.'
    else
        run mkdir -p -- "$HOME/.local/state/nebula" "$HOME/.cache/wal" "$repo_dir/ghostty/themes"
        run matugen image "$repo_dir/quickshell/nebula/assets/default.jpg"
    fi

    printf '\n%s%s  %s%s\n\n' "$bold" "$accent" "$(if "$dry_run"; then printf 'Preview complete'; else printf 'Ready to go'; fi)" "$reset"
    [[ -z $backup_dir ]] || say "Config backups: $backup_dir"
    say 'Log out, choose Hyprland on your login screen, then log in.'
    say 'No login screen? Start Hyprland from a TTY with: Hyprland'
    say 'Tap Super for the launcher. Super + T opens a terminal.'
    say 'Open the gear → Settings to choose your wallpaper, display and keyboard layout.'
    printf '\n'
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
