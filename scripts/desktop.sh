#!/bin/bash

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
      pkg gdm \
        dbus \
        gnome-shell \
        gnome-session \
        gnome-settings-daemon \
        gnome-control-center \
        gnome-terminal \
        gsettings-desktop-schemas \
        nautilus \
        gnome-keyring \
        gnome-tweaks
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
