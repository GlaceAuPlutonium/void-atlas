#!/usr/bin/env bash

set -e

echo "Updating system and installing packages..."

read -p "Perform global system update ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Updating system..."
  sudo xbps-install -Su
else
  echo "Skipped system update."
fi

read -p "Install SHELL related components ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Installing shell stuff..."
  sudo xbps-install -S bash zsh kitty starship
else
  echo "Skipped shell stuff installation."
fi

read -p "Install SYSINFO related components ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Installing system infos stuff..."
  sudo xbps-install -S fastfetch btop bottom htop nvtop duf lm_sensors
else
  echo "Skipped system infos stuff installation."
fi

read -p "Install YAZI related components ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Installing yazi stuff..."
  sudo xbps-install -S yazi ffmpeg6 7zip jq poppler fd ripgrep fzf zoxide resvg ImageMagick wl-clipboard trash-cli
else
  echo "Skipped yazi stuff installation."
fi

read -p "Install DESKTOP related components ? (DOES NOT INSTALL NOCTALIA) [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Installing desktop stuff..."
  sudo xbps-install -S niri wofi mako swaylock wlogout slurp grim wl-clipboard cliphist wlr-randr wlsunset xdg-desktop-portal xdg-desktop-portal-wlr xwayland-satellite playerctl brightnessctl ddcutil
else
  echo "Skipped desktop installation."
fi

read -p "Install MEDIA related components ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Installing media stuff..."
  sudo xbps-install -S pipewire pulseaudio-utils helvum pavucontrol cava mpv imv ffmpeg6 ffplay6 gpu-screen-recorder zathura zathura-pdf-mupdf 
else
  echo "Skipped media stuff installation."
fi

read -p "Install LOOK/MISCS related components ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Installing other stuff..."
  sudo xbps-install -S nwg-look qt6ct gtk-engine-murrine nerd-fonts-symbols-ttf noto-fonts-ttf noto-fonts-emoji dejavu-fonts-ttf font-awesome wget curl git openssh ntfs-3g udisks2 udiskie 7zip cmatrix asciiquarium
else
  echo "Skipped other stuff installation."
fi

read -p "all the remaining random stuff ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Installing random stuff..."
  sudo xbps-install -S sassc rav1e x264 x265 dav1d man-pages wev xdg-user-dirs xdg-utils libinput
else
  echo "Skipped random installation."
fi

echo "Packages installed."
