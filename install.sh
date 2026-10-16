#!/usr/bin/env bash

# 01-PACKAGES


set -e

echo "Welcome to the installer!"

read -r "Perform packages installation ? [Enter/Ctrl+C] : " answer

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

read -p "Install SYSTEM related components ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Installing system infos stuff..."
  sudo xbps-install -S wget curl git openssh ntfs-3g udisks2 udiskie 7zip
else
  echo "Skipped system infos stuff installation."
fi

read -p "Install SYSINFO related components ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Installing system infos stuff..."
  sudo xbps-install -S fastfetch btop htop nvtop amdgpu_top duf lm_sensors
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
  sudo xbps-install -S niri wofi slurp grim wl-clipboard cliphist wlr-randr wlsunset xwayland-satellite playerctl brightnessctl ddcutil
else
  echo "Skipped desktop installation."
fi

read -p "Install MEDIA related components ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Installing media stuff..."
  sudo xbps-install -S pipewire pulseaudio-utils helvum pavucontrol cava mpv imv ffmpeg6 ffplay6 zathura zathura-pdf-mupdf
else
  echo "Skipped media stuff installation."
fi

read -p "Install LOOK/MISCS related components ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Installing other stuff..."
  sudo xbps-install -S nwg-look qt6ct gtk-engine-murrine nerd-fonts-symbols-ttf noto-fonts-ttf noto-fonts-emoji dejavu-fonts-ttf font-awesome cmatrix asciiquarium
else
  echo "Skipped other stuff installation."
fi

read -p "all the remaining random stuff i don't know how to classify ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Installing random stuff..."
  sudo xbps-install -S rav1e x264 x265 dav1d man-pages wev xdg-user-dirs xdg-utils libinput
else
  echo "Skipped random installation."
fi

echo "Packages installed."


# 02-SETUP

read -r "Perform setup ? [Enter/Ctrl+C] : " answer

echo "Setting up annoying system related things..."

# Noctalia
read -p "Add Voiders repository ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Creating Voiders repository..."
  echo "repository=https://repo.voiders.dev/void" | sudo tee /etc/xbps.d/10-voiders-community.conf
  sudo xbps-install -s
else
  echo "Skipped Voiders repository creation."
fi
read -p "Install Noctalia Shell ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Installing Noctalia Shell..."
  echo "Currently can't install Noctalia from distant repo due to it being deprecated. Noctalia install process will be added later. Skipping installation."
  #sudo xbps-install -S
  #sudo xbps-install noctalia
else
  echo "Skipped Noctalia Shell installation."
fi

# Pipewire
read -p "Set up Pipewire ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Setting up Pipewire..."
  sudo usermod -aG audio,video "$USER"
  sudo mkdir -p /etc/pipewire/pipewire.conf.d
  sudo ln -s -f /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/
  sudo ln -s -f /usr/share/examples/pipewire/20-pipewire-pulse.conf /etc/pipewire/pipewire.conf.d/
else
  echo "Skipped Pipewire setup."
fi

echo "Done setting up annoying little things."



# 03-EXTRAS

read -r "Perform extras installation ? [Enter/Ctrl+C] : " answer

echo "Installing themes and extras..."

# CaskaydiaCove Font
read -p "Install CaskaydiaCove font ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Installing font..."
  mkdir -p ~/.local/share/fonts/CascadiaCode
  curl -fSL https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/CascadiaCode.zip -o /tmp/CascadiaCode.zip \
  && 7zip x -y -o"$HOME/.local/share/fonts/CascadiaCode" /tmp/CascadiaCode.zip \
  && fc-cache -f
else
  echo "Skipped font installation."
fi

# TokyoNight GTK Theme
read -p "Install Tokyonight GTK Theme ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Installing GTK theme..."
  sudo xbps-install -S sassc
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

# Zed
read -p "Install Zed ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
  echo "Installing Zed..."
  curl -f https://zed.dev/install.sh | sh
else
  echo "Skipped Zed installation."
fi

# Visor
echo "You may choose to install Visor-BootManager. ⚠️ If you do so and won't use the UKI setup later in the script, PLEASE comment the entries at the bottom of files/visor/boot.conf if you haven't already."
read -p "Install Visor-BootManager ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then

  echo "Installing Visor..."
  sudo xbps-install -S gnu-efi-libs gcc make

  wget -O - https://github.com/IO-ZetZor/Visor-BootManager/archive/refs/tags/v1.5.6.tar.gz | tar xzf -
  cp files/visor/icons/* Visor-BootManager-1.5.6/assets/icons/
  cp files/visor/backgrounds/* Visor-BootManager-1.5.6/assets/backgrounds/
  cp files/visor/gui_blur.c Visor-BootManager-1.5.6/src/gui/gui_blur.c
  chmod +x Visor-BootManager-1.5.6/install.sh
  make -C Visor-BootManager-1.5.6
  cd Visor-BootManager-1.5.6 && sudo ./install.sh --boot-entry && cd ..
  sudo cp files/visor/boot.conf /boot/efi/EFI/visor/

  echo "Visor has been installed. ⚠️ If you won't use the UKI setup later in the script, PLEASE comment the entries at the bottom of /boot/efi/EFI/visor/boot.conf if you haven't already."
else
  echo "Skipped Visor-BootManager installation."
fi

echo "Extras installed."


# 04-CONFIG

read -r "Perform dotfiles installation ? [Enter/Ctrl+C] : " answer

echo "Copying dotfiles..."

mkdir -p ~/Pictures

cp -r .config ~/
cp .zshrc ~/
cp .zsh_plugins.txt ~/

git clone --depth 1 https://codeberg.org/GlaceAuPlutonium/void-atlas-wp ~/Pictures

echo "Dotfiles installed."


#05 FIND A APPROPRIATE NAME FOR THIS SECTION

read -r "Perform specific configuration ? [Enter/Ctrl-C] : "

# Polkit
read -p "Add polkit rules ? [1] NetworkManager | [2] udisks2 | [3] GameMode | [4] All | [n] Skip : " choice
if [[ "$choice" == 1 ]]; then
    sudo cp files/polkit/50-nm-wheel.rules /etc/polkit-1/rules.d/
elif [[ "$choice" == 2 ]]; then
    sudo cp files/polkit/50-udisks.rules /etc/polkit-1/rules.d/
elif [[ "$choice" == 3 ]]; then
    sudo cp files/polkit/51-gamemode.rules /etc/polkit-1/rules.d/
elif [[ "$choice" == 4 ]]; then
    sudo cp files/polkit/50-nm-wheel.rules /etc/polkit-1/rules.d/
    sudo cp files/polkit/50-udisks.rules /etc/polkit-1/rules.d/
    sudo cp files/polkit/51-gamemode.rules /etc/polkit-1/rules.d/
else
  echo "Skipped Antidote installation."
fi

# resolvconf
read -p "Resolve DNS ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
    sudo resolvconf -u
else
    echo "Skipped DNS resolving."
fi

# Bluetooth
read -p "Install bluez ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
    echo "Installing bluez..."
    sudo xbps-install -S bluez libva-bluetooth
    sudo ln -s /etc/sv/bluetoothd /var/service/
    read -p "Disable bluetooth on startup ? [y/n] : " bt
    if [[ "$bt" == "y" ]]; then
        cp files/main.conf /etc/bluetooth/main.conf
    fi
else
    echo "Skipped bluez installation."
fi

# upower
read -p "Install upower ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
    sudo xbps-install -S upower
else
    echo "Skipped upower resolving."
fi

# mpv-mpris
read -p "Install mpv-mpris ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
    sudo xbps-install -S mpv-mpris
else
    echo "Skipped mpv-mpris resolving."
fi

# ACPI handler.sh
read -p "Modify ACPI handler.sh ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
    sudo cp files/handler.sh /etc/acpi/handler.sh
else
    echo "Skipped ACPI handler.sh modification."
fi

# WiFi  powersave
read -p "Disable WiFi powersave ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
    sudo cp files/default-wifi-powersave-on.conf /etc/NetworkManager/conf.d/
else
    echo "Skipped wifi powersave disabling."
fi

# NOTE MAYBE ADD AN OPTION TO COPY FSTAB DIRECTLY,  JUST NEED TO CHANGE THE UUID VALUE INSIDE THE FILE

# debugfs
read -p "Enable debugfs ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
    echo "debugs /sys/kernel/debug debugfs defaults 0 0" | sudo tee -a /etc/fstab
else
    echo "Skipped debugfs."
fi

# modprobe wifi options
read -p "Desperately try to fix the wifi by disabling some options through modprobe ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
    sudo cp files/mt7921.conf files/mt7921e.conf /etc/modprobe.d/
else
    echo "Skipped wifi modprobe option prob aint working anyway."
fi

# GREETD ONCE I ADD GREETD

# dumb_runtime_dir
read -p "Install dumb_runtime_dir ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
    sudo xbps-install -S dumb_runtime_dir
    echo "session    optional   pam_dumb_runtime_dir.so" | sudo tee -a /etc/pam.d/system-login
else
    echo "Skipped dumb_runtime_dir installation."
fi

# rc.local
read -p "Change rc.local ? [y/n] : " choice
if [[ "$choice" == "y" ]]; then
    sudo cp files/rc.local /etc/rc.local
else
    echo "Skipped rc.local modification."
fi

# BTRFS AND BTRBK

# STOPPED AT 27/07
# STEAM
# GAMEMODE
#
