#!/bin/bash

backup_files(){
  files=$(find ./config/ -maxdepth 2  | sed  "s/^config\///g"|sed -r '/^\s*$/d')
  backup_directory="$HOME/_dotfiles_backup_$(date +'%Y%m%d%H%M%S/')"
  mkdir -p "$backup_directory"
  for file in $files; do
    cp -r "$file" -t "$backup_directory"
  done
}

install_config(){
sudo apt install\
    bspwm \
    kitty \
    neovim \
    polybar \
    rofi \
    sxhkd \
    flameshot \
    pamixer \
    brightnessctl \
    i3lock-color \
    feh \
    libnotify-bin \
    xclip \
    dmenu \
    betterlockscreen \
    lxappearance \
    lsd \
    bat \
    pavucontrol \
    xfce4-screensaver \
    xfce4-power-manager \
    xfce4-goodies \
    xfce4 \
    shellcheck

# global install of neovim
sudo wget -q https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz -O /dev/shm/nvim-linux64.tar.gz
sudo tar -xzf /dev/shm/nvim-linux64.tar.gz -C /dev/shm/
sudo mv /dev/shm/nvim-linux64/bin/* /usr/local/bin/
sudo mv /dev/shm/nvim-linux64/lib/* /usr/local/lib/
sudo mv /dev/shm/nvim-linux64/share/man/man1/nvim.1  /usr/local/share/man/man1/

#global install of FiraCode nerd font 
sudo wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraCode.zip -O /dev/shm/FiraCode.zip
sudo unzip /dev/shm/FiraCode.zip -d /usr/share/fonts/FiraCode

# global install of theme
sudo cp -rv "$(pwd)/icons" "/usr/share/"
sudo cp -rv "$(pwd)/themes" "/usr/share/"

# local user condig install 
cp -rv "$(pwd)/config/*" "$HOME"
}

if [ "$EUID" -eq 0 ]; then
  if [ -z "$SUDO_UID" ] || [ "$SUDO_UID" -ne 0 ]; then
    printf "[!] Please run the script with sudo, not as the root user\n"
    exit 1
  fi
else
  printf "[!] Please run this script with sudo\n"
  printf "Usage: sudo bash %s\n" "$0"
  exit 1
fi

backup_files
install_config
