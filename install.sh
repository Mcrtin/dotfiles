#!/bin/bash

# Require no permissions
if [[ $UID == 0 ]]; then
    echo "Please run this script without sudo."
    exit 1
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR

# Copy dotfiles
cp -rT .config ~/.config 

# Install Catppuccin for grub
git clone https://github.com/catppuccin/grub.git

sudoFunc () {

    # Must be running as sudo
    if [[ $UID != 0 ]]; then
        echo "Please run this script with sudo."
        exit 1
    fi

    # Configure etc
    cp -rfT etc /etc

    systemctl enable systemd-networkd.service 
    systemctl enable systemd-resolved.service 
    systemctl enable iwd.service
    
    # Instaall Catppuccin for grub
    cp -r grub/src/* /usr/share/grub/themes/
    echo "GRUB_THEME=\"/usr/share/grub/themes/catppuccin-mocha-grub-theme/theme.txt\"" >> /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg

    # Install packages
    pacman -S --needed man-db tldr git base-devel neovim qutebrowser translate-shell brightnessctl spotifyd pulseaudio pavucontrol rofi aerc lazygit tmux dunst alacritty ttf-jetbrains-mono-nerd fprintd copyq lightdm-webkit2-greeter

}

FUNC=$(declare -f sudoFunc)
sudo -H bash -c "$FUNC; sudoFunc $*;"



systemctl enable --user spotifyd.service


if ! command -v yay &> /dev/null
then
    # Install yay
    git clone https://aur.archlinux.org/yay-bin.git && (cd yay-bin && makepkg -si)
fi


yay -S --needed spotify-tui catppuccin-gtk-theme-mocha libinput-gestures lightdm-webkit-theme-aether --noconfirm




# Install LazyVim
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git


# Install Catppuccin for Rofi
git clone https://github.com/catppuccin/rofi.git
(cd rofi/basic/ && bash install.sh)


# Install Catppuccin for alacritty
curl -LO --output-dir ~/.config/alacritty https://github.com/catppuccin/alacritty/raw/main/catppuccin-mocha.toml
# Install Catppuccin for qute
git clone https://github.com/catppuccin/qutebrowser.git ~/.config/qutebrowser/catppuccin
# Install Catppucccin for spotify-tui
git clone https://github.com/catppuccin/spotify-tui.git && mkdir ~/.config/spotify-tui/ && cp spotify-tui/mocha.yml ~/.config/spotify-tui/


echo "To finish setup change the account details in .config/spotifyd/spotifyd.conf"