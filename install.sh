#!/bin/bash

# Require no permissions
if [[ $UID == 0 ]]; then
    echo "Please run this script without sudo."
    exit 1
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
HOMEDIR=$HOME

sudoFunc () {

    # Must be running as sudo
    if [[ $UID != 0 ]]; then
        echo "Please run this script without sudo."
        exit 1
    fi

    systemctl enable systemd-networkd.service 
    systemctl enable systemd-resolved.service 
    systemctl enable iwd.service

    # Configure X11
    cp -rT $SCRIPT_DIR/etc /etc
    

    # Install packages
    pacman -S --needed man-db tldr git base-devel neovim qutebrowser translate-shell brightnessctl spotifyd pavucontrol rofi aerc lazygit tmux dunst alacritty ttf-jetbrains-mono-nerd fprintd copyq

    

}

FUNC=$(declare -f sudoFunc)
sudo -H bash -c "$FUNC; sudoFunc $*;"

yay -S spotify-tui catppuccin-gtk-theme-mocha libinput-gestures --noconfirm


# Copy dotfiles
cp -rT $SCRIPT_DIR/.config $HOMEDIR/.config 

# Install LazyVim
git clone https://github.com/LazyVim/starter $HOMEDIR/.config/nvim
rm -rf $HOMEDIR/.config/nvim/.git


# Install yay
git clone https://aur.archlinux.org/yay-bin.git && (cd yay-bin && makepkg -si)

# Install Catppuccin for Rofi
git clone https://github.com/catppuccin/rofi.git
bash rofi/basic/install.sh


# Install Catppuccin for alacritty
curl -LOC --output-dir $HOMEDIR/.config/alacritty https://github.com/catppuccin/alacritty/raw/main/catppuccin-mocha.toml
# Install Catppuccin for qute
git clone https://github.com/catppuccin/qutebrowser.git $HOMEDIR/.config/qutebrowser/catppuccin
# Install Catppucccin for spotify-tui
git clone https://github.com/catppuccin/spotify-tui.git && cp spotify-tui/mocha.yml $HOMEDIR/.config/spotify-tui/

# Remove this clone
cd SCRIPT_DIR
cd ..
rm -rf SCRIPT_DIR