#!/usr/bin/env bash
# Installation Hyprland + rice macOS-like (Arch Linux)
#
#   ./install.sh                  paquets + configs
#   ./install.sh --skip-packages  configs uniquement
#
# Les fichiers existants dans ~/.config sont sauvegardés avant d'être remplacés.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_DIR="$CONFIG_DIR/rice-backup-$(date +%Y%m%d-%H%M%S)"
MIN_HYPRLAND="0.56"   # première version avec la config Lua

PACKAGES=(
  # Hyprland et son écosystème
  hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
  hyprpaper hyprlock hypridle hyprpolkitagent
  # Bureau
  kitty waybar wofi swaync nwg-dock-hyprland nwg-drawer nautilus
  # Wayland / Qt
  qt5-wayland qt6-wayland
  # Capture, presse-papiers, matériel
  grim slurp wl-clipboard cliphist brightnessctl playerctl
  # Son
  pipewire pipewire-pulse wireplumber pavucontrol
  # Polices et icônes
  ttf-jetbrains-mono-nerd inter-font noto-fonts papirus-icon-theme
)

info() { printf '\033[1;34m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m!!\033[0m %s\n' "$*" >&2; exit 1; }

skip_packages=false
for arg in "$@"; do
  case "$arg" in
    --skip-packages) skip_packages=true ;;
    -h|--help) sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) die "Option inconnue : $arg" ;;
  esac
done

# ── Prérequis ────────────────────────────────────────────────────
[[ $EUID -ne 0 ]] || die "Lance ce script en utilisateur normal (sudo est appelé quand il faut)."
command -v pacman >/dev/null || die "Ce script est prévu pour Arch Linux (pacman introuvable)."

if ! $skip_packages; then
  command -v sudo >/dev/null || die "sudo est requis pour installer les paquets."
  info "Installation des paquets"
  sudo pacman -Syu --needed --noconfirm "${PACKAGES[@]}"
fi

if command -v Hyprland >/dev/null; then
  version="$(pacman -Q hyprland 2>/dev/null | awk '{print $2}')"
  if [[ -n $version && $(vercmp "$version" "$MIN_HYPRLAND") -lt 0 ]]; then
    die "Hyprland $version trop ancien : la config Lua demande Hyprland >= $MIN_HYPRLAND."
  fi
else
  warn "Hyprland n'est pas installé : configs copiées quand même."
fi

# ── Configs ──────────────────────────────────────────────────────
backup() {
  local target="$1" rel="${1#"$CONFIG_DIR"/}"
  mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
  mv "$target" "$BACKUP_DIR/$rel"
}

info "Copie des configs dans $CONFIG_DIR"
while IFS= read -r -d '' src; do
  rel="${src#"$REPO_DIR/config/"}"
  dest="$CONFIG_DIR/$rel"
  if [[ -e $dest ]] && ! cmp -s "$src" "$dest"; then
    backup "$dest"
  fi
  install -Dm644 "$src" "$dest"
done < <(find "$REPO_DIR/config" -type f -print0)

# Une ancienne hyprland.conf serait ignorée au profit de hyprland.lua : on la range.
[[ -e $CONFIG_DIR/hypr/hyprland.conf ]] && backup "$CONFIG_DIR/hypr/hyprland.conf"

# Apps épinglées du dock (seulement au premier lancement : l'utilisateur les modifie ensuite)
PINNED="${XDG_CACHE_HOME:-$HOME/.cache}/nwg-dock-pinned"
if [[ ! -e $PINNED ]]; then
  mkdir -p "$(dirname "$PINNED")"
  printf '%s\n' org.gnome.Nautilus kitty > "$PINNED"
fi

info "Copie des fonds d'écran"
install -Dm644 -t "$CONFIG_DIR/hypr/wallpapers" "$REPO_DIR"/wallpapers/*

[[ -d $BACKUP_DIR ]] && info "Anciens fichiers sauvegardés dans $BACKUP_DIR"

# ── Vérification ─────────────────────────────────────────────────
if command -v Hyprland >/dev/null; then
  if Hyprland --verify-config 2>&1 | grep -q '^config ok'; then
    info "Config Hyprland valide"
  else
    warn "La config Hyprland a des erreurs :"
    Hyprland --verify-config 2>&1 | sed -n '/parsing result/,$p' >&2
  fi
fi

info "Terminé. Choisis la session « Hyprland » sur l'écran de connexion."
