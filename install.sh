#!/usr/bin/env bash

# 01-PACKAGES

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



# 02-SETUP

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



# 03-EXTRAS

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

echo "Extras installed."



# 04-CONFIG

echo "Copying dotfiles..."

mkdir -p ~/.local/share/fonts

mkdir -p ~/Pictures

cp -r .config ~/
cp -r Wallpapers ~/Pictures
cp -r .local/share/fonts/CascadiaCode ~/.local/share/fonts/

cp .zshrc ~/
cp zsh_plugins.txt ~/

echo "Dotfiles installed."
