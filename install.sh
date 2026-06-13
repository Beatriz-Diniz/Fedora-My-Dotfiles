#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

PACKAGES=(
  git
  stow
  zsh

  hyprland
  hyprlock
  hypridle
  xdg-desktop-portal-hyprland

  sddm
  sddm-themes

  waybar
  wofi
  rofi-wayland
  wlogout
  dunst

  kitty
  fastfetch
  btop

  wl-clipboard
  cliphist
  grim
  slurp
  swappy

  brightnessctl
  playerctl
  pavucontrol

  NetworkManager-tui
  bluez
  bluez-tools

  polkit
  polkit-gnome

  qt5ct
  qt6ct
  kvantum
  nwg-look
)

install_packages() {
  local available_packages=()

  for pkg in "${PACKAGES[@]}"; do
    if dnf -q info "$pkg" >/dev/null 2>&1; then
      available_packages+=("$pkg")
    else
      echo "Package not found in enabled repos: $pkg"
    fi
  done

  if [ "${#available_packages[@]}" -gt 0 ]; then
    sudo dnf install -y "${available_packages[@]}"
  fi
}

backup_path() {
  local target="$1"

  if [ -e "$target" ] || [ -L "$target" ]; then
    local relative_path="${target#$HOME/}"
    local backup_target="$BACKUP_DIR/$relative_path"

    mkdir -p "$(dirname "$backup_target")"
    mv "$target" "$backup_target"
    echo "Backed up: $target -> $backup_target"
  fi
}

backup_home_conflicts() {
  backup_path "$HOME/.zshrc"
  backup_path "$HOME/.zprofile"
  backup_path "$HOME/.zshenv"
  backup_path "$HOME/.p10k.zsh"

  backup_path "$HOME/.config/hypr"
  backup_path "$HOME/.config/hyde"
  backup_path "$HOME/.config/waybar"
  backup_path "$HOME/.config/wofi"
  backup_path "$HOME/.config/rofi"
  backup_path "$HOME/.config/wlogout"
  backup_path "$HOME/.config/dunst"
  backup_path "$HOME/.config/kitty"
  backup_path "$HOME/.config/fastfetch"
  backup_path "$HOME/.config/btop"
  backup_path "$HOME/.config/swappy"
  backup_path "$HOME/.config/gtk-3.0"
  backup_path "$HOME/.config/gtk-4.0"
  backup_path "$HOME/.config/qt5ct"
  backup_path "$HOME/.config/qt6ct"
  backup_path "$HOME/.config/Kvantum"
  backup_path "$HOME/.config/nwg-look"
  backup_path "$HOME/.config/environment.d"
  backup_path "$HOME/.config/systemd"

  backup_path "$HOME/.config/mimeapps.list"
  backup_path "$HOME/.config/user-dirs.dirs"
  backup_path "$HOME/.config/user-dirs.locale"
  backup_path "$HOME/.config/brave-flags.conf"
  backup_path "$HOME/.config/code-flags.conf"
  backup_path "$HOME/.config/kdeglobals"

  backup_path "$HOME/.local/share/bin"
}

link_home_files() {
  mkdir -p "$HOME/.config"
  mkdir -p "$HOME/.local/share"

  cd "$DOTFILES_DIR"
  stow --target="$HOME" home
}

install_fonts() {
  sudo mkdir -p /usr/local/share/fonts/nerd-fonts

  if [ -d "$DOTFILES_DIR/home/.local/share/fonts" ]; then
    find "$DOTFILES_DIR/home/.local/share/fonts" \
      -type f \
      \( -iname "JetBrainsMono*NerdFont*.ttf" -o -iname "JetBrainsMonoNL*NerdFont*.ttf" \) \
      -exec sudo cp {} /usr/local/share/fonts/nerd-fonts/ \;
  fi

  if [ -d "$HOME/.local/share/fonts" ]; then
    find "$HOME/.local/share/fonts" \
      -type f \
      \( -iname "JetBrainsMono*NerdFont*.ttf" -o -iname "JetBrainsMonoNL*NerdFont*.ttf" \) \
      -exec sudo cp {} /usr/local/share/fonts/nerd-fonts/ \;
  fi

  sudo fc-cache -fv
}

install_pokemon_colorscripts() {
  if [ -d "$DOTFILES_DIR/system/usr/local/opt/pokemon-colorscripts" ]; then
    sudo mkdir -p /usr/local/opt
    sudo rm -rf /usr/local/opt/pokemon-colorscripts

    sudo cp -a \
      "$DOTFILES_DIR/system/usr/local/opt/pokemon-colorscripts" \
      /usr/local/opt/pokemon-colorscripts

    sudo ln -sf \
      /usr/local/opt/pokemon-colorscripts/pokemon-colorscripts.py \
      /usr/local/bin/pokemon-colorscripts

    sudo chmod +x /usr/local/opt/pokemon-colorscripts/pokemon-colorscripts.py

    echo "pokemon-colorscripts installed from dotfiles"
  else
    echo "pokemon-colorscripts source not found in dotfiles"
  fi
}

install_sddm_configs() {
  if [ -d "$DOTFILES_DIR/system/etc/sddm.conf.d" ]; then
    sudo mkdir -p /etc/sddm.conf.d

    for conf in "$DOTFILES_DIR"/system/etc/sddm.conf.d/*; do
      [ -e "$conf" ] || continue

      local conf_name
      conf_name="$(basename "$conf")"

      sudo rm -f "/etc/sddm.conf.d/$conf_name"
      sudo ln -s "$conf" "/etc/sddm.conf.d/$conf_name"

      echo "Linked SDDM config: $conf_name"
    done
  fi
}

install_sddm_themes() {
  if [ -d "$DOTFILES_DIR/system/usr/share/sddm/themes" ]; then
    sudo mkdir -p /usr/share/sddm/themes

    for theme in "$DOTFILES_DIR"/system/usr/share/sddm/themes/*; do
      [ -e "$theme" ] || continue

      local theme_name
      theme_name="$(basename "$theme")"

      sudo rm -rf "/usr/share/sddm/themes/$theme_name"
      sudo ln -s "$theme" "/usr/share/sddm/themes/$theme_name"

      echo "Linked SDDM theme: $theme_name"
    done
  fi
}

install_system_files() {
  install_fonts
  install_pokemon_colorscripts
  install_sddm_configs
  install_sddm_themes
}

enable_services() {
  if systemctl list-unit-files | grep -q '^sddm.service'; then
    sudo systemctl enable sddm.service
  fi

  if systemctl list-unit-files | grep -q '^bluetooth.service'; then
    sudo systemctl enable bluetooth.service
  fi
}

set_zsh_default() {
  if command -v zsh >/dev/null 2>&1; then
    local zsh_path
    zsh_path="$(command -v zsh)"

    if [ "$SHELL" != "$zsh_path" ]; then
      chsh -s "$zsh_path"
    fi
  fi
}

main() {
  echo "Installing packages"
  install_packages

  echo "Backing up existing files"
  backup_home_conflicts

  echo "Creating symlinks"
  link_home_files

  echo "Installing system files"
  install_system_files

  echo "Enabling services"
  enable_services

  echo "Setting zsh as default shell"
  set_zsh_default

  echo "Done"
  echo "Backup directory: $BACKUP_DIR"
}

main "$@"