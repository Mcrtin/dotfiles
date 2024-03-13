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
    pacman -S --needed man-db tldr git base-devel jack2 neovim qutebrowser translate-shell brightnessctl spotifyd pulseaudio pavucontrol rofi aerc lazygit tmux dunst alacritty ttf-jetbrains-mono-nerd fprintd copyq lightdm-webkit2-greeter xorg-xdpyinfo exa starship discord playerctl pamixer s-nail neofetch awk arandr zoxide jre-openjdk picom iwd networkmanager iio-sensor-proxy noto-fonts-emoji sysstat python python-requests lm_sensors --noconfirm

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


yay -S --needed spotify-tui catppuccin-gtk-theme-mocha libinput-gestures lightdm-webkit-theme-aether polybar auto-cpufreq betterlockscreen networkmanager --noconfirm

systemctl enable --user spotifyd.service

sudo systemctl enable betterlockscreen@$USER.service
sudo systemctl enable auto-cpufreq

# Configure Bash
cp -f .bashrc ~


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

feh --bg-scale ~/.config/wallpapers/background.png
betterlockscreen -u ~/.config/wallpapers/background.png

git clone https://github.com/miklhh/i3blocks-config.git
(cd i3blocks-config && yes | bash install.sh)

echo -e "\033[1;36mTo finish setup, change the account details in file://~/.config/spotifyd/spotifyd.conf and change the weather forecast URL in file://~/.config/i3blocks/weather
/weather.py \e[0m"