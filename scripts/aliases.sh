#!/bin/bash

install_aliases() {
  local alias_file shell_rc marker_start marker_end

  alias_file="${SCRIPT_DIR}/aliases.sh"
  shell_rc="${HOME}/.bashrc"
  marker_start="# postinstall aliases start"
  marker_end="# postinstall aliases end"

  if [[ ! -f "${alias_file}" ]]; then
    echo "Aliases file not found: ${alias_file}"
    return 1
  fi

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    echo "[INFO] [DRY RUN] Would install aliases from ${alias_file} to ${shell_rc}"
    return 0
  fi

  if [[ -f "${shell_rc}" ]] && grep -q "${marker_start}" "${shell_rc}"; then
    sed -i "/${marker_start}/,/${marker_end}/d" "${shell_rc}"
  fi

  {
    echo ""
    echo "${marker_start}"
    cat "${alias_file}"
    echo "${marker_end}"
  } >> "${shell_rc}"
}
