#!/usr/bin/env bash

DOTFILES="$HOME/.dotFiles"
cd || exit

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

