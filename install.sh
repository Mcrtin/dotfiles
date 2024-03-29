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

    # Instaall Catppuccin for grub
    cp -r grub/src/* /usr/share/grub/themes/

    echo "GRUB_GFXMODE=$(xdpyinfo | grep dimensions | sed -r 's/^[^0-9]*([0-9]+x[0-9]+).*$/\1/')" >> /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
    
    systemctl enable systemd-networkd.service 
    systemctl enable systemd-resolved.service 
    

    
    
    # Update all packages
    pacman -Syu --noconfirm

    # Removing i3lock so it doesn't conlict with i3lock-color for betterlockscreen
    paman -Rs i3lock --noconfirm

    # Install packages
    pacman -S --needed --noconfirm man-db tldr git base-devel jack2 neovim firefox translate-shell \
    brightnessctl spotifyd pulseaudio pavucontrol rofi aerc lazygit tmux dunst alacritty \
    ttf-jetbrains-mono-nerd fprintd copyq lightdm-webkit2-greeter xorg-xdpyinfo exa starship \
    discord playerctl pamixer s-nail neofetch awk arandr zoxide jre-openjdk picom iwd networkmanager \
    network-manager-applet iio-sensor-proxy noto-fonts-emoji sysstat python python-requests lm_sensors \
    acpi fzf dust btop python-neovim xclip powertop fd ripgrep nodejs tree-sitter-cli mpv
    
    systemctl enable NetworkManager.service
    systemctl enable iio-sensor-proxy

}

FUNC=$(declare -f sudoFunc)
sudo -H bash -c "$FUNC; sudoFunc $*;"



brightnessctl set 30%

if ! command -v yay &> /dev/null
then
    # Install yay
    git clone https://aur.archlinux.org/yay-bin.git && (cd yay-bin && makepkg -si)
fi


yay -S --needed --noconfirm spotify-tui catppuccin-gtk-theme-mocha papirus-folders-catppuccin-git \
libinput-gestures lightdm-webkit-theme-aether auto-cpufreq betterlockscreen networkmanager \
pulseaudio-ctl xkb-switch youtube-viewer tmux-plugin-manager


systemctl enable --user pulseaudio
systemctl enable --user spotifyd.service

sudo systemctl enable betterlockscreen@$USER.service
sudo systemctl enable auto-cpufreq

# Configure Bash
cp -f .bashrc ~

cp -f .Xresources ~

cp -f .tmux.conf ~
cp -f .tmux.reset.conf ~


# Install LazyVim
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git


# Install Catppuccin for Rofi
git clone https://github.com/catppuccin/rofi.git
(cd rofi/basic/ && bash install.sh)


# Install Catppuccin for alacritty
curl -LO --output-dir ~/.config/alacritty https://github.com/catppuccin/alacritty/raw/main/catppuccin-mocha.toml

# Install Catppucccin for spotify-tui
git clone https://github.com/catppuccin/spotify-tui.git && mkdir ~/.config/spotify-tui/ && cp spotify-tui/mocha.yml ~/.config/spotify-tui/

feh --bg-scale ~/.config/wallpapers/background.png
betterlockscreen -u ~/.config/wallpapers/background.png

echo -e "\033[1;36mTo finish setup, change the account details in file://$(cd && pwd)/.config/spotifyd/spotifyd.conf \e[0m"