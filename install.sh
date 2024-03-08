# Require permissions
if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

systemctl enable systemd-networkd.service 
systemctl enable systemd-resolved.service 
systemctl enable iwd.service

# Configure X11
cp -rT ./etc /etc
# Copy dotfiles
sudo -u USERNAME cp -rT .config ~/.config

# Install packages
pacman -S --needed man-db tldr git base-devel neovim qutebrowser translate-shell brightnessctl pavucontrol rofi aerc lazygit tmux dunst alacritty ttf-jetbrains-mono-nerd fprintd copyq

# Install LazyVim
sudo -u USERNAME git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

# Install yay
git clone https://aur.archlinux.org/yay-bin.git && (cd yay-bin && sudo -u USERNAME makepkg -si)

yay -S spotify-tui catppuccin-gtk-theme-mocha libinput-gestures --noconfirm

# Install Catppuccin for Rofi
git clone https://github.com/catppuccin/rofi.git
bash rofi/basic/install.sh

# Install Catppuccin for alacritty
sudo -u USERNAME curl -LOC --output-dir ~/.config/alacritty https://github.com/catppuccin/alacritty/raw/main/catppuccin-mocha.toml
# Install Catppuccin for qute
sudo -u USERNAME git clone https://github.com/catppuccin/qutebrowser.git ~/.config/qutebrowser/catppuccin
sudo -u USERNAME git clone https://github.com/catppuccin/spotify-tui.git && cp spotify-tui/mocha.yml ~/.config/spotify-tui/