#!/bin/bash

set -euo pipefail

log_info() {
  echo "[INFO] $*"
}

log_error() {
  echo "[ERROR] $*" >&2
}

is_dry_run() {
  [[ "${DRY_RUN:-0}" == "1" ]]
}

run_cmd() {
  if is_dry_run; then
    log_info "[DRY RUN] $*"
    return 0
  fi

  "$@"
}

run_cmd_force() {
  "$@"
}

run_with_retries() {
  local attempt max_attempts delay

  if is_dry_run; then
    log_info "[DRY RUN] $*"
    return 0
  fi

  max_attempts=3
  delay=2

  for attempt in $(seq 1 "${max_attempts}"); do
    if "$@"; then
      return 0
    fi

    log_error "Command failed (attempt ${attempt}/${max_attempts}): $*"
    sleep "${delay}"
  done

  log_error "Command failed after ${max_attempts} attempts: $*"
  return 1
}

run_with_retries_force() {
  local attempt max_attempts delay

  max_attempts=3
  delay=2

  for attempt in $(seq 1 "${max_attempts}"); do
    if "$@"; then
      return 0
    fi

    log_error "Command failed (attempt ${attempt}/${max_attempts}): $*"
    sleep "${delay}"
  done

  log_error "Command failed after ${max_attempts} attempts: $*"
  return 1
}

pkg() {
  if [[ "$#" -eq 0 ]]; then
    return 0
  fi

  run_with_retries sudo pacman -S --needed --noconfirm "$@"
}

update_system() {
  run_with_retries sudo pacman -Syu --noconfirm
}

install_paru() {
  if is_dry_run; then
    log_info "[DRY RUN] Would install paru from AUR"
    return 0
  fi

  if ! command -v paru >/dev/null; then
    pkg git base-devel
    run_with_retries git clone https://aur.archlinux.org/paru.git /tmp/paru
    (cd /tmp/paru && run_with_retries makepkg -si --noconfirm)
  else
    echo "Paru already installed"
  fi
}

aur_pkg() {
  install_paru
  if [[ "$#" -eq 0 ]]; then
    return 0
  fi

  run_with_retries paru -S --needed --noconfirm "$@"
}

ensure_gum() {
  if command -v gum &> /dev/null; then
    return 0
  fi

  log_info "Installing gum"
  run_with_retries_force sudo pacman -S --needed --noconfirm gum
}

setup_git() {
  local git_name git_email

  if is_dry_run; then
    log_info "[DRY RUN] Would set git user.name, user.email, and core.editor"
    return 0
  fi

  git_name="$(gum input --placeholder "Git user.name")"
  git_email="$(gum input --placeholder "Git user.email")"

  if [[ -n "${git_name}" ]]; then
    run_cmd git config --global user.name "${git_name}"
  fi

  if [[ -n "${git_email}" ]]; then
    run_cmd git config --global user.email "${git_email}"
  fi

  run_cmd git config --global core.editor "vim"
}

install_tailscale() {
  local auth_key

  log_info "Installing Tailscale"
  pkg tailscale
  run_cmd sudo systemctl enable --now tailscaled

  auth_key="${TAILSCALE_AUTHKEY:-}"
  if [[ -z "${auth_key}" ]]; then
    auth_key="$(gum input --placeholder "TAILSCALE_AUTHKEY (leave blank for login URL)")"
  fi

  if [[ -n "${auth_key}" ]]; then
    run_cmd sudo tailscale up --authkey "${auth_key}" --accept-routes
  else
    run_cmd sudo tailscale up --accept-routes
  fi
}
