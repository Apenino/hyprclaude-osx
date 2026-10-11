# hyprclaude-osx

Rice Hyprland sobre façon macOS pour Arch Linux : barre en haut (waybar), dock (nwg-dock) avec grille d'applications (nwg-drawer), lanceur façon Spotlight (wofi), centre de notifications (swaync), écran de verrouillage (hyprlock), flou et coins arrondis.

La config Hyprland est écrite en **Lua** (`hyprland.lua`) : le format `hyprland.conf` est obsolète à partir de Hyprland 0.57. Il faut **Hyprland ≥ 0.56**.

## Installation

```sh
git clone git@github.com:Apenino/hyprclaude-osx.git
cd hyprclaude-osx
./install.sh
```

Le script :

1. installe les paquets nécessaires avec `pacman` ;
2. copie `config/` dans `~/.config/` et les fonds d'écran dans `~/.config/hypr/wallpapers/` ;
3. sauvegarde tout fichier existant différent dans `~/.config/rice-backup-<date>/` (y compris une ancienne `hyprland.conf`) ;
4. vérifie la config avec `Hyprland --verify-config`.

`./install.sh --skip-packages` ne fait que copier les configs.

Il faut ensuite choisir la session **Hyprland** sur l'écran de connexion (GDM, SDDM…).

## Raccourcis

`Super` joue le rôle de `⌘`.

| Raccourci | Action |
|---|---|
| `Super + Entrée` | Terminal (kitty) |
| `Super + Espace` | Lanceur d'applications |
| `Super + E` | Fichiers (Nautilus) |
| `Super + Q` | Fermer la fenêtre |
| `Super + F` | Plein écran |
| `Super + V` | Fenêtre flottante |
| `Super + L` | Verrouiller |
| `Super + N` | Notifications |
| `Super + Shift + V` | Historique du presse-papiers |
| `Super + Shift + 3` / `4` | Capture plein écran / zone (copiée) |
| `Super + flèches` | Changer de fenêtre |
| `Super + Shift + flèches` | Déplacer la fenêtre |
| `Super + 1…9` | Aller au bureau (touches AZERTY) |
| `Super + Ctrl + 1…9` | Envoyer la fenêtre sur le bureau |
| `Super + Tab` / `Shift + Tab` | Bureau suivant / précédent |
| `Super + Shift + M` | Quitter Hyprland |

## Structure

```
config/
├── hypr/               hyprland.lua, hyprlock, hypridle, hyprpaper
├── waybar/
├── kitty/
├── wofi/
├── swaync/
├── nwg-dock-hyprland/
└── xdg-terminals.list
wallpapers/
install.sh
```

## Notes

- Le clavier est réglé en `fr` (AZERTY) : à changer dans `config/hypr/hyprland.lua` (`kb_layout`).
- `cursor.no_hardware_cursors` est activé pour les machines virtuelles (sinon le curseur peut être invisible). Sur une machine physique, on peut le retirer.
- En config Lua, `hyprctl dispatch` attend une expression Lua, par exemple `hyprctl dispatch 'hl.dsp.dpms({ action = "off" })'`.
