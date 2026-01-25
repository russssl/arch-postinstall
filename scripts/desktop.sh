#!/bin/bash

install_gnome_extensions() {
  local list_file extension_id

  list_file="${SCRIPT_DIR}/gnome-extensions.txt"

  pkg gnome-extension-manager
  aur_pkg gnome-extensions-cli

  if [[ ! -f "${list_file}" ]]; then
    echo "GNOME extensions list not found: ${list_file}"
    return 0
  fi

  while IFS= read -r extension_id; do
    if [[ -z "${extension_id}" ]] || [[ "${extension_id}" == \#* ]]; then
      continue
    fi

    run_cmd gext install "${extension_id}"
  done < "${list_file}"
}

enable_display_manager() {
  local service_name

  service_name="${1}"

  if [[ -z "${service_name}" ]]; then
    return 1
  fi

  run_cmd sudo systemctl enable --now "${service_name}"
}

install_desktop() {
  local choice

  choice="$(gum choose "GNOME" "KDE Plasma" "XFCE" "Hyprland")"

  case "${choice}" in
    "GNOME")
      pkg gnome gnome-extra
      install_gnome_extensions
      enable_display_manager gdm
      ;;
    "KDE Plasma")
      pkg plasma kde-applications
      enable_display_manager sddm
      ;;
    "XFCE")
      pkg xfce4 xfce4-goodies
      ;;
    "Hyprland")
      pkg hyprland
      enable_display_manager sddm
      ;;
  esac
}
