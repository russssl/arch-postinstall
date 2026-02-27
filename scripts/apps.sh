#!/bin/bash

install_apps() {
  pkg mpv extension-manager
  aur_pkg cursor-bin \
    helium-browser-bin \
    google-chrome \
    jellyfin-desktop \
    feishin-bin \
    discord \
    spotify \
    deluge \
    obsidian \
    thunderbird
}
