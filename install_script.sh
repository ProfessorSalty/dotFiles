#!/usr/bin/env bash

# TODO
# Colorize the output
if [ ! -d $HOME/Projects/go ]; then
    mkdir -p ~/Projects/go/bin
fi

DOTFILES=$HOME/.dotFiles
XDG_CONFIG_HOME=$HOME/.config
GOPATH=$HOME/Projects/go
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

if [ ! -d $HOME/.config ]; then
    echo "Adding ~/.config..."
    mkdir -p $XDG_CONFIG_HOME
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
    brew install coreutils moreutils findutils tidy-html5 hub gpg-agent mongodb reattach-to-user-namespace tmux zsh python tree shellcheck postgres mysql heroku-toolbelt redis go go-delve/delve/delve neofetch
    brew install wget --with-iri
    brew install vim --override-system-vi
    brew cask install gpgtools
    echo "Cleaning up..."
    brew cleanup
elif [ $DISTRO == "UBUNTU" ]; then
    # for Heroku
    echo "deb https://cli-assets.heroku.com/branches/stable/apt ./" > /etc/apt/sources.list.d/heroku.list
    wget -qO- https://cli-assets.heroku.com/apt/release.key | apt-key add -
    # nexcloud client
    sudo add-apt-repository ppa:nextcloud-devs/client
    # for GO
    sudo add-apt-repository ppa:longsleep/golang-backports
    apt-get update
    sudo apt-get install -y autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev neovim python-neovim python3-neovim tmux zsh python postgresql postgresql-contrib tcl shellcheck golang-go mysql-server heroku python3-pip tree feh rofi xbacklight pulseaudio-utils compton xfce4-power-manager nextcloud-client rxvt-unicode neofetch geary
    sudo mysql_secure_installation
    # build hub
    git clone https://github.com/github/hub.git
    cd hub || return
    make install prefix=/usr/local
    cd .. || return
    rm -rf hub
    #build redis
    curl -O http://download.redis.io/redis-stable.tar.gz
    tar xzvf redis-stable.tar.gz
    cd redis-stable || return
    make
    sudo make install
    sudo mkdir /etc/redis
    sudo cp /tmp/redis-stable/redis.conf /etc/redis
    #html-tidy5
    wget https://github.com/htacg/tidy-html5/releases/download/5.4.0/tidy-5.4.0-64bit.deb
    sudo dpkg -i tidy-5.4.0-64bit.deb
    rm tidy-5.4.0-64bit.deb
elif [ $DISTRO == "MANJAROLINUX" ]; then
    sudo yaourt -S --aur --noconfirm --force tmux feh rofi neovim shellcheck python-pip zsh zsh-completions go python-neovim postgresql mariadb compton xorg-xbacklight hub redis powerline powerline-fonts xorg-xmodmap geary neofetch
    yaourt -S --aur --noconfirm nextcloud-client tidy-html5 ruby-build node-build tdrop wire-desktop
fi
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

#get oh-my-zsh
if [ ! -d ~/.oh-my-zsh ]; then
    echo "Installing oh-my-zsh..."
    git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
fi

if [ ! -d ~/.rbenv ]; then
    git clone --depth=1 https://github.com/rbenv/rbenv.git $HOME/.rbenv
    echo "Initializing rbenv..."
    eval "$($HOME/.rbenv/bin/rbenv init)"
    rubyversion=$(rbenv install -l | grep -v - | tail -1 | sed -e 's/^[[:space:]]*//')
    echo "Downloading Ruby $rubyversion..."
    rbenv install "$rubyversion"
    rbenv global "$rubyversion"
fi

if [ ! -d ~/.nodenv ]; then
    git clone --depth=1 https://github.com/nodenv/nodenv.git ~/.nodenv
    echo "Initializing nodenv..."
    eval "$($HOME/.nodenv/bin/nodenv init)"
    nodeversion=$(nodenv install -l | grep -E "^[^a-zA-Z]*([0-9]+\.){2}[0-9]+$" | tail -1 | tr -d ' ')
    echo "Downloading Node $nodeversion..."
    nodenv install "$nodeversion"
    nodenv global "$nodeversion"
fi

if [ -z "$(which pip)" ]; then
    #need to install pip
    sudo easy_install pip
fi
if [ "$(which pip)" ]; then
    pip install --upgrade pip
fi

if [ "$(which pip3)" ]; then
    pip3 install --upgrade pip3
fi

echo "Installing NPM modules..."
sudo npm install -g eslint eslint-plugin-babel eslint-plugin-html eslint-plugin-react esformatter esformatter-jsx tern stylelint_d less babel-core babel-cli babel-preset-es2015 eslint_d typescript jsbeautify

#dotNet
if [ -z "$(which dotnet)" ]; then
    mkdir -p /usr/local/lib
    ln -s /usr/local/opt/openssl/lib/libcrypto*.dylib /usr/local/lib/
    ln -s /usr/local/opt/openssl/lib/libssl*.dylib /usr/local/lib/
    echo "Downloading dotNet Core to $(~/Downloads)..."
    wget -O ~/Downloads/dotnet.pkg https://go.microsoft.com/fwlink/?LinkID=835011
    echo "Installing dotNet Core..."
    sudo installer -pkg ~/Downloads/dotnet.pkg -target /
fi

#Install globals for Sublime Text plugins
echo "Installing important gems..."
gem install rubocop haml scss_lint rails bundler capistrano tmuxinator travis

echo "Installing powerline-status..."
pip3 install  powerline-status

echo "Installing powerline fonts..."
git clone --depth=1 https://github.com/powerline/fonts.git ~/Downloads/powerline-fonts
cd ~/Downloads/powerline-fonts || exit
chmod +x ./install.sh
sh ./install.sh
cd && rm -rf ~/Downloads/powerline-fonts

echo "Installing Font-Awesome..."
git clone --depth=1 https://github.com/FortAwesome/Font-Awesome.git ~/Downloads/font-awesome
cd ~/Downloads/font-awesome/fonts || exit
if [ $OS == "LINUX" ]; then
    cp *.tff ~/.local/share/fonts
elif [ $OS == "MAC" ]; then
    sudo cp *.tff /Library/Fonts/
fi

#should clone dotFiles repo only if ~/.dotFiles does not exist
if [ ! -d $DOTFILES ]; then
    echo "Cloning dotFiles..."
    git clone --depth=1 https://github.com/PortableStick/dotFiles.git $DOTFILES
    wait $!
fi

for FILEPATH in $DOTFILES/rcfiles/*; do
    FILENAME=${FILEPATH##*/}
    echo "Linking $FILENAME...";
    if [ -L ~/.$FILENAME ]; then
        rm ~/.$FILENAME
        echo "Removing $FILENAME..."
    fi
    ln -s $FILEPATH ~/.$FILENAME
done
if [ ! -d ~/.config/powerline/themes/tmux ]; then
    echo "Linking tmux powerline theme file..."
    mkdir -p ~/.config/powerline/themes/tmux
fi
if [ -f ~/.config/powerline/themes/tmux/default.json ]; then
    rm ~/.config/powerline/themes/tmux/default.json
fi
ln -s $DOTFILES/tmux/config/powerline/themes/tmux/default.json ~/.config/powerline/themes/tmux/default.json
echo "Linking tmux.conf..."
if [ -f ~/.tmux.conf ]; then
    rm ~/.tmux.conf
fi
ln -s $DOTFILES/tmux/tmux.conf ~/.tmux.conf
echo "Linking zshrc..."
if [ -f ~/.zshrc ]; then
    rm ~/.zshrc
fi
ln -s $DOTFILES/zsh/zshrc ~/.zshrc
if [ -f ~/.config/nvim/init.vim ]; then
    rm ~/.config/nvim/init.vim
fi
ln -s $DOTFILES/rcfiles/vimrc ~/.config/nvim/init.vim
echo "Linking zprofile..."
if [ -f ~/.zprofile ]; then
    rm ~/.zprofile
fi
ln -s $DOTFILES/zsh/zprofile ~/.zprofile
echo "Linking zlogin..."
if [ -f ~/.zlogin ]; then
    rm ~/.zlogin
fi
ln -s $DOTFILES/zsh/zlogin ~/.zlogin
echo "Linking zpath..."
if [ -f ~/.zpath ]; then
    rm ~/.zpath
fi
ln -s $DOTFILES/zsh/zpath ~/.zpath
echo "Linking zshenv..."
if [ -f ~/.zshenv ]; then
    rm ~/.zshenv
fi
ln -s $DOTFILES/zsh/zshenv ~/.zshenv

# Other stuff
if [  ! -d ~/.ssh ] || [ ! -f ~/.ssh/id_rsa ]; then
    echo "Generating RSA keypair - you'll need to enter a passphrase..."
    ssh-keygen -t rsa -b 4096
fi

if [ ! -f ~/.ssh/config ]; then
    ln -s $DOTFILES/ssh/config ~/.ssh/
fi

if [ $OS == "MAC" ] && [ ! -d /usr/local/var/mysql ]; then
    echo "Setting up MySQL...."
    unset TMPDIR
    mkdir /usr/local/var
    mysql_install_db --verbose --user="$(whoami)" --basedir="$(brew --prefix mysql)" --datadir=/usr/local/var/mysql --tmpdir=/tmp
fi

if [ ! -d /usr/local/var/postgres ]; then
    echo "Setting up PostGres...."
    postgres -D /usr/local/var/postgres
fi

if [ $OS == "LINUX" ]; then
    mkdir -p "$HOME/.i3/config"
    if [ -f "$HOME/.i3/config" ]; then
        rm "$HOME/.i3/config"
    fi
    ln -s $DOTFILES/i3/config $HOME/.i3

    if [ -f "$XDG_CONFIG_HOME/compton.conf" ]; then
        rm "$XDG_CONFIG_HOME/compton.conf"
    fi
    ln -s "$DOTFILES/compton/compton.conf" "$XDG_CONFIG_HOME"
fi

# Setup NeoVim
#if [ ! -f $XDG_CONFIG_HOME/nvim/.vim ]; then
    #ln -s ~/.vim $XDG_CONFIG_HOME/nvim
#fi
if [ ! -d $XDG_CONFIG_HOME/nvim ]; then
    mkdir -p $XDG_CONFIG_HOME/nvim
fi
if [ ! -f $XDG_CONFIG_HOME/nvim/init.vim ]; then
    ln -s ~/.vimrc $XDG_CONFIG_HOME/nvim/init.vim
fi
if [ ! -d $HOME/.local/share/nvim/site/autoload ]; then
 curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

if [ $OS == "MAC" ]; then
    # sets xcode for node
    sudo xcode-select -switch /usr/bin
fi

# set zsh as default
chsh -s "$(which zsh)"
# install vim-plug
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

nvim +PlugInstall +qall
#Get the information we need first, if we need it
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
git config --global core.excludesfile ~/.gitignore_global
#make note to use mysql_secure_installation
echo "Install and setup complete.  Now run the setup script."
