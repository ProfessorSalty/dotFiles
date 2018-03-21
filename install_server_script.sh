#!/usr/bin/env bash

font_dir="$HOME/.local/share/fonts"
mkdir -p "$font_dir"

if [ ! -d "$HOME/.config" ]; then
    echo "Adding ~/.config..."
    mkdir -p "$XDG_CONFIG_HOME"
fi

echo "Installing packages..."
{
  sudo apt-get install -yqq apt-transport-https
  sudo apt-get update
  sudo apt-get dist-upgrade -yqq
  sudo apt-get install -yqq git
  sudo apt-get install -yqq autoconf build-essential libssl-dev libyaml-dev libreadline-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev neovim python-neovim python3-neovim tmux zsh postgresql postgresql-contrib tree gawk curl
  alias awk=gawk
} >> /dev/null

if [ -z $(which git) ]; then
    echo "Git is not installed for some reason"
    exit 1
fi
#get oh-my-zsh
if [ ! -d ~/.oh-my-zsh ]; then
    echo "Installing oh-my-zsh..."
    git clone -q --depth=1 https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
fi

if [ ! -d ~/.oh-my-zsh/themes/geometry ]; then
    echo "Installing geometry theme for oh-my-zsh..."
    git clone -q --depth=1 https://github.com/geometry-zsh/geometry ~/.oh-my-zsh/themes/geometry >> /dev/null

    cd ~/.oh-my-zsh/themes/geometry || return
    git submodule update -q --init --recursive >> /dev/null
fi

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
cd
sudo rm -rf "$HACK"

echo "Installing Nerd patched fonts..."
NF="$DOWNLOADS/nerdfonts"
if [ ! -d "$NF" ]; then
    git clone --depth=1 https://github.com/ryanoasis/nerd-fonts.git "$NF"
fi
cd "$NF" || exit
./install.sh >> /dev/null
cd && rm -rf "$NF"

#should clone dotFiles repo only if ~/.dotFiles does not exist
if [ ! -d "$DOTFILES" ]; then
    echo "Cloning dotFiles..."
    git clone --depth=1 https://github.com/PortableStick/dotFiles.git "$DOTFILES" >> /dev/null
    wait $!
fi

for FILEPATH in $DOTFILES/rcfiles/*; do
    FILENAME=${FILEPATH##*/}
    echo "Linking $FILENAME...";
    if [ -L ~/."$FILENAME" ]; then
        rm ~/."$FILENAME"
    fi
    ln -s "$FILEPATH" ~/."$FILENAME"
done

for FILEPATH in $DOTFILES/bin/*;do
    FILENAME=${FILEPATH##*/}
    echo "Linking $FILENAME...";
    if [ -L /usr/local/bin/"$FILENAME" ]; then
        sudo rm  /usr/local/bin/"$FILENAME"
        echo "Removing $FILENAME..."
    fi
    chmod +x "$FILEPATH"
    sudo ln -s "$FILEPATH" /usr/local/bin/"$FILENAME"
done

if [ ! -d ~/.config/powerline/themes/tmux ]; then
    echo "Linking tmux powerline theme file..."
    mkdir -p ~/.config/powerline/themes/tmux
fi
if [ -f ~/.config/powerline/themes/tmux/default.json ]; then
    rm ~/.config/powerline/themes/tmux/default.json
fi
ln -s "$DOTFILES"/tmux/config/powerline/themes/tmux/default.json ~/.config/powerline/themes/tmux/default.json
echo "Linking tmux.conf..."
if [ -f ~/.tmux.conf ]; then
    rm ~/.tmux.conf
fi
ln -s "$DOTFILES"/tmux/tmux.conf ~/.tmux.conf
echo "Linking zshrc..."
if [ -f ~/.zshrc ]; then
    rm ~/.zshrc
fi
ln -s "$DOTFILES"/zsh/zshrc ~/.zshrc
if [ -f ~/.config/nvim/init.vim ]; then
    rm ~/.config/nvim/init.vim
else
    mkdir -p ~/.config/nvim
fi
ln -s "$DOTFILES"/rcfiles/vimrc ~/.config/nvim/init.vim
echo "Linking zprofile..."
if [ -f ~/.zprofile ]; then
    rm ~/.zprofile
fi
ln -s "$DOTFILES"/zsh/zprofile ~/.zprofile
echo "Linking zlogin..."
if [ -f ~/.zlogin ]; then
    rm ~/.zlogin
fi
ln -s "$DOTFILES"/zsh/zlogin ~/.zlogin
echo "Linking zpath..."
if [ -f ~/.zpath ]; then
    rm ~/.zpath
fi
ln -s "$DOTFILES"/zsh/zpath ~/.zpath
echo "Linking zshenv..."
if [ -f ~/.zshenv ]; then
    rm ~/.zshenv
fi
ln -s "$DOTFILES"/zsh/zshenv ~/.zshenv

# install vim-plug
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim >> /dev/null

chown -R "$USERPERMISSIONS" ~/.local

sudo -u "$SUDO_USER" nvim +PlugInstall +qall

# set zsh as default
echo "Setting zsh as default shell..."
sudo -u "$SUDO_USER" chsh -s "$(which zsh)"
echo "Install and setup complete.  Now run the setup script."
