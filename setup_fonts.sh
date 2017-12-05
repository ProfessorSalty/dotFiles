#!/usr/bin/env bash

DOWNLOADS="$HOME/Downloads"
OS="UNKNOWN"
DISTRO="OTHER"

case "$OSTYPE" in
    linux*)
        OS="LINUX"
        DISTRO="$(lsb_release -irc | grep Distributor | awk '{print toupper($3)}')"
        echo "Preparing installation for $DISTRO"
        ;;
    darwin*)
        OS="MAC"
        echo "Preparing installation for macOS"
        ;;
esac

if [ $OS == "MAC" ]; then
    font_dir="$HOME/Library/Fonts"
else
    font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"
fi

if [ ! -d "$HOME/.config" ]; then
    echo "Adding ~/.config..."
    mkdir -p "$XDG_CONFIG_HOME"
fi

cd || exit
echo "Installing powerline fonts..."
PL="$DOWNLOADS/powerline-fonts"
git clone --depth=1 https://github.com/powerline/fonts.git "$PL"
cd "$PL" || exit
chmod +x ./install.sh
./install.sh >> /dev/null
cd && rm -rf "$PL"

echo "Installing Font-Awesome..."
FA="$DOWNLOADS/Font-Awesome"
git clone --depth=1 https://github.com/FortAwesome/Font-Awesome.git "$FA"
cd "$FA" || exit
cp "$(find "$FA" -name '*.[o,t]tf' -or -name '*.pcf.gz' -type f -print0)" "$font_dir/" >> /dev/null
cd && rm -rf "$FA"

echo 'Installing Hack (font)...'
HACK="$DOWNLOADS/HACK"
if [ ! -d "$HACK" ]; then
    git clone --depth=1 https://github.com/source-foundry/Hack.git "$HACK"
fi
cd "$HACK" || exit
cp "$(find "$HACK" -name '*.[o,t]tf' -or -name '*.pcf.gz' -type f -print0)" "$font_dir/" >> /dev/null
cd || exit
sudo rm -rf "$HACK"

echo "Installing Nerd patched fonts..."
NF="$DOWNLOADS/nerdfonts"
if [ ! -d "$NF" ]; then
    git clone --depth=1 https://github.com/ryanoasis/nerd-fonts.git "$NF"
fi
cd "$NF" || exit
./install.sh >> /dev/null
cd && rm -rf "$NF"

