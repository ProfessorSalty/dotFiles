#! /bin/bash

# TODO
# Check for powerline fonts somehow
# Backup and retrieve applications somehow
# Colorize the output

#Make sure we don't get blocked by xcode license
xcode-select --install
sudo xcodebuild -license accept
#Get the information we need first, if we need it
if  [ -z "$(git config --global user.name)" ]; then
    echo "Please enter your name (for git config): "
    read -r gitname
    git config --global user.name "$gitname"
fi
if  [ -z "$(git config --global user.email)" ]; then
    echo "Please enter the email you associate with git (for git config): "
    read -r gitemail
    git config --global user.email "$gitemail"
fi

#Install Homebrew
if [ -z "$(which brew)" ]; then
    echo "Installing Homebrew..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
echo "Updating Homebrew..."
brew update
echo "Installing important packages..."
brew tap samueljohn/python
brew tap homebrew/science
brew install coreutils moreutils findutils tidy-html5 hub gpg-agent mongodb macvim reattach-to-user-namespace tmux zsh python tree rbenv nodenv imagemagick shellcheck postgres zeromq pyqt gcc numpy scipy mysql heroku-toolbelt redis
brew install wget --with-iri
brew install vim --override-system-vi
echo "Cleaning up..."
brew cleanup

#get oh-my-zsh
if [ ! -d ~/.oh-my-zsh ]; then
    echo "Installing oh-my-zsh..."
    git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
fi

if [ ! -d ~/.rbenv ]; then
    echo "Initializing rbenv..."
    rbenv init
    rubyversion=$(rbenv install -l | grep -v - | tail -1)
    echo "Downloading Ruby $rubyversion..."
    rbenv install "$rubyversion"
    rbenv global "$rubyversion"
fi

if [ ! -d ~/.nodenv ]; then
    echo "Initializing nodenv..."
    nodenv init
    nodeversion=$(nodenv install -l | grep -E "^[^a-zA-Z]*([0-9]+\.){2}[0-9]+$" | tail -1 | tr -d ' ')
    echo "Downloading Node $nodeversion..."
    nodenv install "$nodeversion"
    nodenv global "$nodeversion"
fi

pip install --upgrade distribute
pip install --upgrade pip

pip install venv
pip install ipython[zmq,qtconsole,notebook,test]

echo "Installing NPM modules..."
sudo npm install -g eslint eslint-plugin-babel eslint-plugin-html eslint-plugin-react esformatter esformatter-jsx tern stylelint_d less

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
pip install powerline-status

echo "Installing powerline fonts..."
git clone --depth=1 https://github.com/powerline/fonts.git ~/Downloads/powerline-fonts
cd ~/Downloads/powerline-fonts || exit
chmod +x ./install.sh
sh ./install.sh
cd && rm -rf ~/Downloads/powerline-fonts

git config --global credential.helper osxkeychain

mkdir -p ~/Projects

#should clone dotFiles repo only if ~/.dotFiles does not exist
if [ ! -d ~/.dotFiles ]; then
    echo "Cloning dotFiles..."
    git clone --depth=1 https://github.com/PortableStick/dotFiles.git ~/.dotFiles
    wait $!
fi

for FILEPATH in ~/.dotFiles/rcfiles/*; do
    FILENAME=${FILEPATH##*/}
    echo "Linking $FILENAME...";
    if [ -f ~/.$FILENAME ]; then
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
ln -s ~/.dotFiles/tmux/config/powerline/themes/tmux/default.json ~/.config/powerline/themes/tmux/default.json
echo "Linking tmux.conf..."
if [ -f ~/.tmux.conf ]; then
    rm ~/.tmux.conf
fi
ln -s ~/.dotFiles/tmux/tmux.conf ~/.tmux.conf
echo "Linking zshrc..."
if [ -f ~/.zshrc ]; then
    rm ~/.zshrc
fi
ln -s ~/.dotFiles/zsh/zshrc ~/.zshrc
echo "Linking zprofile..."
if [ -f ~/.zprofile ]; then
    rm ~/.zprofile
fi
ln -s ~/.dotFiles/zsh/zprofile ~/.zprofile
echo "Linking zlogin..."
if [ -f ~/.zlogin ]; then
    rm ~/.zlogin
fi
ln -s ~/.dotFiles/zsh/zlogin ~/.zlogin
echo "Linking zpath..."
if [ -f ~/.zpath ]; then
    rm ~/.zpath
fi
ln -s ~/.dotFiles/zsh/zpath ~/.zpath
echo "Linking zshenv..."
if [ -f ~/.zshenv ]; then
    rm ~/.zshenv
fi
ln -s ~/.dotFiles/zsh/zshenv ~/.zshenv

# setup vim
if [ -f ~/.vim ]; then
    rm -rf ~/.vim
fi
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
    curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
cd ~/.vim/bundle
git clone git://github.com/tpope/vim-sensible.git
cd

# Visual studio code
echo "Installing VSCode and saved settings..."
if [ -f ~/Library/Application\ Support/Code/User/settings.json ]; then
    rm ~/Library/Application\ Support/Code/User/settings.json
fi
ln -s ~/.dotFiles/vscode/settings.json ~/Library/Application\ Support/Code/User
brew cask install visual-studio-code
if [ -f /usr/local/bin/code ]; then
    rm /usr/local/bin/code
fi
ln -s /Applications/Visual Studio Code.app/Contents/Resources/app/bin/code /usr/local/bin
ln -s ~/.dotFiles/backup_vscode.sh /usr/local/bin/backup_vscode

echo "Installing VSCode extensions..."
for X in $(< ~/.dotFiles/vscode/vscode-extensions.txt); do
    /Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code --install-extension $X
done

git config --global core.excludesfile ~/.gitignore_global

#set zsh as default
chsh -s "$(which zsh)"

if [  ! -d ~/.ssh ] || [ ! -f ~/.ssh/id_rsa ]; then
    echo "Generating RSA keypair - you'll need to enter a passphrase..."
    ssh-keygen -t rsa -b 4096
fi

echo "Setting up MySQL...."
unset TMPDIR
mkdir /usr/local/var
mysql_install_db --verbose --user=`whoami` --basedir="$(brew --prefix mysql)" --datadir=/usr/local/var/mysql --tmpdir=/tmp


echo "Setting up PostGres...."
postgres -D /usr/local/var/postgres

# sets xcode for node
sudo xcode-select -switch /usr/bin

chmod +x ./.dotFiles/setup_mac.sh

echo "Install and setup complete.  Now run the setup script."
