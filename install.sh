#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
fi
export DRY_RUN

source "${SCRIPT_DIR}/scripts/common.sh"
source "${SCRIPT_DIR}/scripts/desktop.sh"
source "${SCRIPT_DIR}/scripts/devtools.sh"
source "${SCRIPT_DIR}/scripts/apps.sh"
source "${SCRIPT_DIR}/scripts/aliases.sh"

ensure_gum

base_packages=(
  base-devel
  git
  gum
  curl
  wget
  tar
  zip
  unzip
  htop
  fastfetch
  vim
  usbutils
)

echo "Updating system"
update_system

echo "Installing base packages"
pkg "${base_packages[@]}"

if gum confirm "Do you want to install Paru?"; then
  install_paru
fi

if gum confirm "Do you want to add default folders for user?"; then
  pkg xdg-user-dirs
  xdg-user-dirs-update
fi

if gum confirm "Do you want to set up Tailscale?"; then
  install_tailscale
fi

if gum confirm "Do you want to install Solaar to manage Logitech devices?"; then
  pkg solaar
fi

if gum confirm "Do you want to install dev tools and apps?"; then
  install_devtools
fi

if gum confirm "Do you want to install apps?"; then
  install_apps
fi

if gum confirm "Do you want to install gaming packages?"; then
  pkg nvidia-open-dkms steam lutris
fi

if gum confirm "Do you want to install shell aliases?"; then
  install_aliases
fi

if gum confirm "Do you want to set up git config?"; then
  setup_git
fi

if gum confirm "Do you want to install a desktop environment?"; then
  install_desktop
fi
