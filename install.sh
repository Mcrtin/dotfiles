# Require permissions
if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

# Configure X11
cp -rT ./etc /etc
# Copy dotfiles
cp -rT .config ~/.config

# Install packages
pacman -S --needed git base-devel nvim qute translate-shell brightnessctl pavucontrol rofi aerc lazygit tmux dunst alacritty ttf-jetbrains-mono-nerd fprintd copyq

# Install LazyVim
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

# Install yay
git clone https://aur.archlinux.org/yay-bin.git && (cd yay-bin && makepkg -si)

yay -S spotify-tui catppuccin-gtk-theme-mocha libinput-gestures --noconfirm

# Install Catppuccin for Rofi
git clone https://github.com/catppuccin/rofi.git
bash install.sh

# Install Catppuccin for alacritty
curl -LO --output-dir ~/.config/alacritty https://github.com/catppuccin/alacritty/raw/main/catppuccin-mocha.toml
# Install Catppuccin for qute
git clone https://github.com/catppuccin/qutebrowser.git ~/.config/qutebrowser/catppuccin
git clone https://github.com/catppuccin/spotify-tui.git && cp spotify-tui/mocha.yml ~/.config/spotify-tui/