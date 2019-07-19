#!/usr/bin/env bash

# TODO
# Colorize the output
if [ ! -d "$HOME/Projects/go" ]; then
    mkdir -p "$HOME/Projects/go/bin"
fi

DOTFILES=$HOME/.dotFiles
DOWNLOADS=$HOME/Downloads
XDG_CONFIG_HOME=$HOME/.config
NODENV=$HOME/.nodenv
RBENV=$HOME/.rbenv
GOPATH=$HOME/Projects/go
USERPERMISSIONS="$USER:$USER"

export GOPATH

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

if  [ $OS == "MAC" ] && [ ! -d  /Applications/Xcode.app ]; then
    echo "Xcode is not installed.  Please install Xcode from the App Store before running this script."
    exit 1
fi
#Make sure we don't get blocked by xcode license
if [ $OS == "MAC" ]; then
    if [ -z "$(xcode-select -p)" ]; then
        xcode-select --install
        sudo xcodebuild -license accept
    else
        echo "Xcode command line tools are already installed"
    fi
fi

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

if [ $OS == "MAC" ]; then
    #Install Homebrew
    if [ -z "$(which brew)" ]; then
        echo "Installing Homebrew..."
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
    echo "Updating Homebrew..."
    brew update
    echo "Installing important packages..."
    brew tap homebrew/science
    brew install coreutils moreutils findutils tidy-html5 hub reattach-to-user-namespace tmux tree shellcheck go neofetch ag ctags leiningen mitmproxy cmake awscli wget vim llvm
    brew cask install gpgtools
    echo "Cleaning up..."
    brew cleanup >> /dev/null

elif [ "$DISTRO" == "UBUNTU" ]; then
    echo "Installing packages..."
    sudo apt-get install -yqq apt-transport-https
    # for Sublime Text
    wget -qO-  https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add - >> /dev/null
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list >> /dev/null
    sudo apt-get update
    sudo apt-get dist-upgrade -yqq
    sudo apt-get install -yqq git
    sudo apt-get install -yqq autoconf bison build-essential libssl-dev libyaml-dev libreadline-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev neovim python-neovim python3-neovim tmux zsh python postgresql postgresql-contrib tcl shellcheck python3-pip tree feh rofi xbacklight pulseaudio-utils compton xfce4-power-manager rxvt-unicode neofetch geary exuberant-ctags gawk curl cmake clang
    # install submlime text
    sudo apt-get install -yqq sublime-text
    # Go from snaps
    sudo snap install --classic go
    #html-tidy5
    wget --quiet https://github.com/htacg/tidy-html5/releases/download/5.4.0/tidy-5.4.0-64bit.deb
    sudo dpkg -i tidy-5.4.0-64bit.deb
    rm tidy-5.4.0-64bit.deb
    #BECAUSE REASONS
    alias awk=gawk

elif [ "$DISTRO" == "MANJAROLINUX" ]; then
    sudo pacman -Syu git tmux shellcheck python-pip zsh zsh-completions go hub powerline powerline-fonts geary neofetch gvim guake 
    #required for ctags vim plugin
    sudo pacman -Syu ctags
    #allows programs that access the keyring on startup to work
    sudo pacman -Syu libgnome-keyring
    sudo pacman -Syu base-devel yaourt
    yaourt -S --aur --noconfirm --force ruby-build nodenv-node-build nextcloud-client wire-desktop bitwarden
    yaourt -S --aur --noconfirm --force clang cmake 
fi
if ! type git; then
    echo "Git is not installed for some reason"
    exit 1
fi

echo "Installing go packages..."
go get -u github.com/nsf/gocode
go get -u github.com/ramya-rao-a/go-outline
go get -u github.com/tpng/gopkgs
go get -u github.com/acroca/go-symbols
go get -u golang.org/x/tools/cmd/guru
go get -u golang.org/x/tools/cmd/gorename
go get -u github.com/fatih/gomodifytags
go get -u github.com/josharian/impl
go get -u github.com/rogpeppe/godef
go get -u sourcegraph.com/sqs/goreturns
go get -u golang.org/x/tools/cmd/goimports
go get -u github.com/golang/lint/golint
go get -u github.com/cweill/gotests/...
go get -u mvdan.cc/sh/cmd/shfmt

#get oh-my-zsh
if [ ! -d ~/.oh-my-zsh ]; then
    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

#install spaceship prompt
SP="$ZSH_CUSTOM/themes/spaceship-prompt"
if [ -d "$SP" ]; then
  rm -rf "$SP"
fi

git clone --dept=1 https://github.com/denysdovhan/spaceship-prompt.git "$SP"
ln -s "$SP/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

if [ ! -d "$RBENV" ]; then
    echo "Initializing rbenv..."
    echo "Cloning rbenv into $RBENV"
    git clone -q --depth=1 https://github.com/rbenv/rbenv.git "$RBENV"
    mkdir -p "$RBENV/plugins"
    RCMD=$RBENV/bin/rbenv
    git clone -q --depth=1 https://github.com/rbenv/ruby-build.git "$($RCMD root)/plugins/ruby-build"
    sudo chown -R "$USERPERMISSIONS" "$RBENV"
    rubyversion=$($RCMD install --list | grep -v - | tail -1 | sed -e 's/^[[:space:]]*//')
    echo "Downloading Ruby $rubyversion..."
    $RCMD install "$rubyversion"
    $RCMD global "$rubyversion"
    echo "Downloading rbenv-update..."
    git clone https://github.com/rkh/rbenv-update.git "$(rbenv root)/plugins/rbenv-update"
fi

if [ ! -d "$NODENV" ]; then
    git clone -q --depth=1 https://github.com/nodenv/nodenv.git "$NODENV"
    echo "Initializing nodenv..."
    echo "Cloning nodenv into $NODENV"
    mkdir -p "$NODENV/plugins"
    NCMD=$NODENV/bin/nodenv
    git clone -q --depth=1 https://github.com/nodenv/node-build.git "$($NCMD root)/plugins/node-build"
    sudo chown -R "$USERPERMISSIONS" "$NODENV"
    NODEVERSION=$($NCMD install --list |  awk '/^[[:space:]]+([[:digit:]]+\.){2,}([[:digit:]]+)$/'  | tail -1 | tr -d ' ')
    echo "Downloading Node $NODEVERSION..."
    $NCMD install "$NODEVERSION"
    LATESTSIX=$($NCMD install --list |  awk '/^[[:space:]]+6\.([[:digit:]]+\.)([[:digit:]]+)$/'  | tail -1 | tr -d ' ')
    echo "Downloading Node $LATESTSIX for compatibility"
    $NCMD install "$LATESTSIX"
    $NCMD global "$LATESTSIX"
    echo "Downloading nodenv-update"
    git clone https://github.com/nodenv/nodenv-update.git "$NODENV"/plugins/nodenv-update
fi

if test easy_install && ! test pip; then
    #need to install pip
    sudo easy_install pip >> /dev/null
fi
if test pip; then
    pip install --upgrade pip >> /dev/null
fi

if test pip3; then
    pip3 install --upgrade pip3 >> /dev/null
    # These are for nvim completion engine
    pip3 install --user jedi psutil setproctitle >> /dev/null
fi

echo "Installing NPM modules..."
npm_config_loglevel=silent sudo "$NODENV/shims/npm" install -g express-generator nativescript react-native-cli typescript create-react-app @angular/cli vue-cli >> /dev/null

echo "Installing important gems..."
"$RBENV/shims/gem" install rubocop haml scss_lint rails bundler capistrano tmuxinator travis >> /dev/null

echo "Installing Nerd patched fonts..."
NF="$DOWNLOADS/nerdfonts"
if [ ! -d "$NF" ]; then
    git clone --depth=1 https://github.com/ryanoasis/nerd-fonts.git "$NF"
fi
cd "$NF" || exit
./install.sh
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

# Other stuff
if [  ! -d ~/.ssh ] || [ ! -f ~/.ssh/id_rsa ]; then
    echo "Generating RSA keypair - you'll need to enter a passphrase..."
    ssh-keygen -t rsa -b 4096
fi

if [ ! -f ~/.ssh/config ]; then
    ln -s "$DOTFILES"/ssh/config ~/.ssh/
fi

if [ $OS == "LINUX" ]; then
    echo "Linking i3 config files..."
    mkdir -p "$HOME/.i3/config"
    if [ -f "$HOME/.i3/config" ]; then
        rm "$HOME/.i3/config"
    fi
    ln -s "$DOTFILES/i3/config" "$HOME/.i3"

    if [ -f "$XDG_CONFIG_HOME/compton.conf" ]; then
        rm "$XDG_CONFIG_HOME/compton.conf"
    fi
    ln -s "$DOTFILES/compton/compton.conf" "$XDG_CONFIG_HOME"
fi

# Install vim plugins via vim-plug
sudo -E vim +PlugInstall +qall

if [ $OS == "MAC" ]; then
    # sets xcode for node
    sudo xcode-select -switch /usr/bin
fi

chown -R "$USERPERMISSIONS" ~/.local

# Set git information
if  [ -z "$(git config --global user.name)" ]; then
    echo "Please enter your full name (for git config): "
    read -r gitname
    git config --global user.name "$gitname"
fi
if  [ -z "$(git config --global user.email)" ]; then
    echo "Please enter the email you associate with git (for git config): "
    read -r gitemail
    git config --global user.email "$gitemail"
fi

git config --global credential.helper osxkeychain

touch "$HOME/.terminfo"
echo "Setting up terminfo..."
for FILEPATH in $DOTFILES/terminfo; do
        tic -o "$HOME/.terminfo " "$FILEPATH"
done

echo "Setting zsh as default shell..."
if [ $OS == "MAC" ]; then
    sudo dscl . -create /Users/$USER UserShell "$(which zsh)"
   else
    sudo -u "$USER" chsh -s "$(which zsh)"
fi

echo "Install and setup complete.  Now run the setup script."
