#!/usr/bin/env bash

set -e

echo "Setting up annoying system related things..."

# Noctalia
read -p "Create Noctalia Shell repository ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Creating Noctalia Shell repository..."
  echo "repository=https://repo.voiders.dev/void" | sudo tee /etc/xbps.d/10-voiders-community.conf
else
  echo "Skipped Noctalia Shell repository creation."
fi
read -p "Install Noctalia Shell ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Installing Noctalia Shell..."
  sudo xbps-install -S
  sudo xbps-install noctalia
else
  echo "Skipped Noctalia Shell installation."
fi

# Pipewire
read -p "Set up Pipewire ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Setting up Pipewire..."
  sudo usermod -aG audio,video gap
  sudo mkdir -p /etc/pipewire/pipewire.conf.d
  sudo ln -s /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/
  sudo ln -s /usr/share/examples/pipewire/20-pipewire-pulse.conf /etc/pipewire/pipewire.conf.d/
else
  echo "Skipped Pipewire setup."
fi

echo "Done setting up annoying little things."
