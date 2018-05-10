#!/usr/bin/env bash

# TODO
# Colorize the output
if [ ! -d "$HOME/Projects/go" ]; then
    mkdir -p ~/Projects/go/bin
fi

DOTFILES=$HOME/.dotFiles
DOWNLOADS=$HOME/Downloads
XDG_CONFIG_HOME=$HOME/.config
NODENV=$HOME/.nodenv
RBENV=$HOME/.rbenv
GOPATH=$HOME/Projects/go
USERPERMISSIONS="$SUDO_USER:$SUDO_USER"

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
    {
        brew tap homebrew/science
        brew install coreutils moreutils findutils tidy-html5 hub gpg-agent mongodb reattach-to-user-namespace tmux zsh python tree shellcheck postgres mysql heroku-toolbelt redis go go-delve/delve/delve neofetch ag ctags leiningen mitmproxy cmake
        brew install wget --with-iri
        brew install vim --override-system-vi
        brew install --with-toolchain llvm
        brew cask install gpgtools
        brew cask install sublime-text
    } > /dev/null
    echo "Cleaning up..."
    brew cleanup >> /dev/null
elif [ "$DISTRO" == "UBUNTU" ]; then
    echo "Installing packages..."
    {
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
    } >> /dev/null
elif [ "$DISTRO" == "MANJAROLINUX" ]; then
    {
        sudo pacman -Syu git tmux shellcheck python-pip zsh zsh-completions go hub powerline powerline-fonts geary neofetch keepassxc gvim nextcloud-client ruby-build node-build wire-desktop guake
        #required for ctags vim plugin
        sudo pacman -Syu ctags
        #sudo yaourt -S --aur --noconfirm --force clang cmake 
    } >> /dev/null
fi
if ! type git &> /dev/null; then
    echo "Git is not installed for some reason"
    exit 1
fi
{
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
} >> /dev/null
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

if [ ! -d "$RBENV" ]; then
    echo "Initializing rbenv..."
    {
        git clone -q --depth=1 https://github.com/rbenv/rbenv.git "$RBENV"
        mkdir -p "$RBENV/plugins"
        RCMD=$RBENV/bin/rbenv
        git clone -q --depth=1 https://github.com/rbenv/ruby-build.git "$($RCMD root)/plugins/ruby-build"
        sudo chown -R "$USERPERMISSIONS" "$RBENV"
        rubyversion=$($RCMD install --list | grep -v - | tail -1 | sed -e 's/^[[:space:]]*//')
    } >> /dev/null
    echo "Downloading Ruby $rubyversion..."
    {
        $RCMD install "$rubyversion"
        $RCMD global "$rubyversion"
    } >> /dev/null
    echo "Downloading rbenv-update..."
    {
      git clone https://github.com/rkh/rbenv-update.git "$(rbenv root)/plugins/rbenv-update"
    } >> /dev/null
fi

if [ ! -d "$NODENV" ]; then
    git clone -q --depth=1 https://github.com/nodenv/nodenv.git "$NODENV"
    echo "Initializing nodenv..."
    {
        mkdir -p "$NODENV/plugins"
        NCMD=$NODENV/bin/nodenv
        git clone -q --depth=1 https://github.com/nodenv/node-build.git "$($NCMD root)/plugins/node-build"
        sudo chown -R "$USERPERMISSIONS" "$NODENV"
        NODEVERSION=$($NCMD install --list |  awk '/^[[:space:]]+([[:digit:]]+\.){2,}([[:digit:]]+)$/'  | tail -1 | tr -d ' ')
    } >> /dev/null
    echo "Downloading Node $NODEVERSION..."
    {
        $NCMD install "$NODEVERSION"
        LATESTSIX=$($NCMD install --list |  awk '/^[[:space:]]+6\.([[:digit:]]+\.)([[:digit:]]+)$/'  | tail -1 | tr -d ' ')
    } >> /dev/null
    echo "Downloading Node $LATESTSIX for compatibility"
    {
        $NCMD install "$LATESTSIX"
        $NCMD global "$LATESTSIX"
    } >> /dev/null
    echo "Downloading nodenv-update"
    {
      git clone https://github.com/nodenv/nodenv-update.git "$NODENV"/plugins/nodenv-update
    } >> /dev/null
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
npm_config_loglevel=silent sudo "$NODENV/shims/npm" install -g express-generator nativescript react-native-cli tern slint_d typescript create-react-app @angular/cli vue-cli >> /dev/null

# TODO - fix for non-macOS systems
#dotNet
if [ $OS == "MAC" ] && [ -z "$(which dotnet)" ]; then
    DOTNET="$DOWNLOADS/dotnet"
    DNETFILES="$DOTNET/dotnet.pkg"
    {
        mkdir -p /usr/local/lib
        ln -s /usr/local/opt/openssl/lib/libcrypto*.dylib /usr/local/lib/
        ln -s /usr/local/opt/openssl/lib/libssl*.dylib /usr/local/lib/
    } >> /dev/null
    echo "Downloading dotNet Core to $DOTNET..."
    wget -qO "$DNETFILES" https://go.microsoft.com/fwlink/?LinkID=835011 >> /dev/null
    echo "Installing dotNet Core..."
    sudo installer -pkg "$DNETFILES" -target / >> /dev/null
fi

#Install globals for Sublime Text plugins
echo "Installing important gems..."
"$RBENV/shims/gem" install rubocop haml scss_lint rails bundler capistrano tmuxinator travis >> /dev/null

echo "Installing powerline-status..."
pip3 install powerline-status >> /dev/null

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

# Other stuff
if [  ! -d ~/.ssh ] || [ ! -f ~/.ssh/id_rsa ]; then
    echo "Generating RSA keypair - you'll need to enter a passphrase..."
    ssh-keygen -t rsa -b 4096
fi

if [ ! -f ~/.ssh/config ]; then
    ln -s "$DOTFILES"/ssh/config ~/.ssh/
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
    echo "Linking i3 config files..."
    {
        mkdir -p "$HOME/.i3/config"
        if [ -f "$HOME/.i3/config" ]; then
            rm "$HOME/.i3/config"
        fi
        ln -s "$DOTFILES/i3/config" "$HOME/.i3"

        if [ -f "$XDG_CONFIG_HOME/compton.conf" ]; then
            rm "$XDG_CONFIG_HOME/compton.conf"
        fi
        ln -s "$DOTFILES/compton/compton.conf" "$XDG_CONFIG_HOME"
    } >> /dev/null
fi

# Setup NeoVim
if [ ! -d "$XDG_CONFIG_HOME"/nvim ]; then
    mkdir -p "$XDG_CONFIG_HOME"/nvim
    ln -s "$DOTFILES"/vim/ftdetect "$XDG_CONFIG_HOME"/nvim/
fi
if [ ! -f "$XDG_CONFIG_HOME"/nvim/init.vim ]; then
    ln -s ~/.vimrc "$XDG_CONFIG_HOME"/nvim/init.vim
fi
if [ ! -d "$HOME"/.local/share/nvim/site/autoload ]; then
 curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim >> /dev/null
fi

if [ $OS == "MAC" ]; then
    # sets xcode for node
    sudo xcode-select -switch /usr/bin
fi

# install vim-plug
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim >> /dev/null

chown -R "$USERPERMISSIONS" ~/.local

sudo -E vim +PlugInstall +qall

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

if [ "$DISTRO" == "UBUNTU" ]; then
    echo "Installing MySQL Server..."
    sudo apt-get -y -qq install mysql-server
    #sudo mysql_secure_installation
    echo "Installing hub..."
    go get github.com/github/hub >> /dev/null
fi

echo "Setting up terminfo..."
for FILEPATH in $DOTFILES/terminfo; do
        tic -o "$HOME/.terminfo " "$FILEPATH"
done

# set zsh as default
echo "Setting zsh as default shell..."
sudo -u "$SUDO_USER" chsh -s "$(which zsh)"
echo "Install and setup complete.  Now run the setup script."
