#!/usr/bin/env bash

set -e

echo "Installing themes and extras..."

# TokyoNight GTK Theme
read -p "Install Tokyonight GTK Theme ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Installing GTK theme..."
  git clone https://github.com/Fausto-Korpsvart/Tokyonight-GTK-Theme
  (cd Tokyonight-GTK-Theme/themes && sudo ./install.sh -n TokyoNight -c dark -l --tweaks black && sudo ./install.sh -n TokyoNight -c dark -s compact -l --tweaks black)
else
  echo "Skipped GTK theme installation."
fi

# MoreWaita Icon Theme
read -p "Install MoreWaita icon theme ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Installing icon theme..."
  git clone https://github.com/somepaulo/MoreWaita.git
  (cd MoreWaita && sudo ./install.sh)
else
  echo "Skipped icon theme installation."
fi

# Phinger Cursor Theme
read -p "Install Phinger Cursors Theme ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Installing cursor theme..."
  wget -cO- https://github.com/phisch/phinger-cursors/releases/latest/download/phinger-cursors-variants.tar.bz2 | sudo tar xfj - -C /usr/share/icons
else
  echo "Skipped cursor theme installation."
fi

# Antidote
read -p "Install Antidote ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Installing Antidote..."
  git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-$HOME}/.antidote
else
  echo "Skipped Antidote installation."
fi

# CyberGRUB
read -p "Install CyberGRUB Theme ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Installing CyberGRUB-2077 GRUB theme..."
  git clone https://github.com/adnksharp/CyberGRUB-2077
  (cd CyberGRUB-2077 && sudo $SHELL ./install.sh -L samurai && sudo grub-mkconfig -o /boot/grub/grub.cfg)
else
  echo "Skipped GRUB theme installation."
fi

echo "Extras installed."
