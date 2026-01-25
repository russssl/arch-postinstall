#!/bin/bash

get_gnome_shell_version() {
  gnome-shell --version | awk '{print $3}'
}

install_gnome_extension_from_ego() {
  local extension_id shell_version info_url download_url
  local extension_dir temp_dir

  extension_id="${1}"
  shell_version="$(get_gnome_shell_version)"
  info_url="https://extensions.gnome.org/extension-info/?uuid=${extension_id}&shell_version=${shell_version}"
  download_url="$(curl -fsSL "${info_url}" | sed -n 's/.*"download_url":"\\([^"]*\\)".*/\\1/p')"

  if [[ -z "${download_url}" ]]; then
    echo "Failed to resolve download URL for ${extension_id}"
    return 1
  fi

  if is_dry_run; then
    log_info "[DRY RUN] Would install GNOME extension ${extension_id}"
    return 0
  fi

  extension_dir="${HOME}/.local/share/gnome-shell/extensions/${extension_id}"
  temp_dir="$(mktemp -d)"

  run_cmd mkdir -p "${extension_dir}"
  run_cmd curl -fsSL "https://extensions.gnome.org${download_url}" -o "${temp_dir}/extension.zip"
  run_cmd unzip -o "${temp_dir}/extension.zip" -d "${extension_dir}"
  run_cmd rm -rf "${temp_dir}"
}

install_gnome_extensions() {
  local list_file extension_id

  list_file="${SCRIPT_DIR}/gnome-extensions.txt"

  pkg extension-manager

  if [[ ! -f "${list_file}" ]]; then
    echo "GNOME extensions list not found: ${list_file}"
    return 0
  fi

  while IFS= read -r extension_id; do
    if [[ -z "${extension_id}" ]] || [[ "${extension_id}" == \#* ]]; then
      continue
    fi

    install_gnome_extension_from_ego "${extension_id}"
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
