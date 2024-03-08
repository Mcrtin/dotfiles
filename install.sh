# Require no permissions
if [[ $UID == 0 ]]; then
    echo "Please run this script without sudo."
    exit 1
fi

# Install yay
git clone https://aur.archlinux.org/yay-bin.git && (cd yay-bin && makepkg -si)
HOMEDIR = $HOME
su

systemctl enable systemd-networkd.service 
systemctl enable systemd-resolved.service 
systemctl enable iwd.service

# Configure X11
cp -rT ./etc /etc
# Copy dotfiles
cp -rT .config $HOMEDIR/.config

# Install packages
pacman -S --needed man-db tldr git base-devel neovim qutebrowser translate-shell brightnessctl pavucontrol rofi aerc lazygit tmux dunst alacritty ttf-jetbrains-mono-nerd fprintd copyq

# Install LazyVim
git clone https://github.com/LazyVim/starter $HOMEDIR/.config/nvim
rm -rf $HOMEDIR/.config/nvim/.git

yay -S spotify-tui catppuccin-gtk-theme-mocha libinput-gestures --noconfirm

# Install Catppuccin for Rofi
git clone https://github.com/catppuccin/rofi.git
bash rofi/basic/install.sh

# Install Catppuccin for alacritty
curl -LOC --output-dir $HOMEDIR/.config/alacritty https://github.com/catppuccin/alacritty/raw/main/catppuccin-mocha.toml
# Install Catppuccin for qute
git clone https://github.com/catppuccin/qutebrowser.git $HOMEDIR/.config/qutebrowser/catppuccin
git clone https://github.com/catppuccin/spotify-tui.git && cp spotify-tui/mocha.yml $HOMEDIR/.config/spotify-tui/