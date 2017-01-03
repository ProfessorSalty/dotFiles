#! /bin/bash

# TODO
# Check for powerline fonts somehow
# Install all dependencies for Sublime plugins (esp typescript)
# Backup and retrieve applications somehow
# Colorize the output

#Make sure we don't get blocked by xcode license
sudo xcodebuild -license accept
#Get the information we need first, if we need it
if  [ -z "$(git config --global user.name)" ]; then
    echo "Please enter your name (for git config): "
    read -r gitname
    git config --global user.name "$gitname"
fi
if  [ -z "$(git config --global user.email)" ]; then
    echo "Please enter your email (for git config): "
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
brew install coreutils moreutils findutils tidy-html5 hub gpg-agent mongodb macvim reattach-to-user-namespace tmux zsh python tree rbenv nodenv imagemagick shellcheck postgres
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
    echo "Downloading Ruby $nodeversion..."
    nodenv install "$nodeversion"
    nodenv global "$nodeversion"
fi

echo "Installing NPM modules for Sublime Text plugins..."
sudo npm install -g eslint eslint-plugin-babel eslint-plugin-html eslint-plugin-react esformatter esformatter-jsx tern stylelint_d

#dotNet
if [ -z "$(which dotnet)" ]; then
    mkdir -p /usr/local/lib
    ln -s /usr/local/opt/openssl/lib/libcrypto.1.0.0.dylib /usr/local/lib/
    ln -s /usr/local/opt/openssl/lib/libssl.1.0.0.dylib /usr/local/lib/
    echo "Downloading dotNet Core to $(~/Downloads)..."
    wget -O ~/Downloads/dotnet.pkg https://go.microsoft.com/fwlink/?LinkID=835011
    echo "Installing dotNet Core..."
    sudo installer -pkg ~/Downloads/dotnet.pkg -target /
fi

#Install globals for Sublime Text plugins
echo "Installing important gems..."
gem install rubocop haml scss_lint rails bundler capistrano tmuxinator

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
if [ ! -d "${HOME}/Library/Application Support/Sublime Text 3/Installed Packages" ]; then
    mkdir -p "${HOME}/Library/Application Support/Sublime Text 3/Installed Packages"
fi
cd "${HOME}/Library/Application Support/Sublime Text 3/Installed Packages" || exit
wget https://packagecontrol.io/Package%20Control.sublime-package
if [ -d "${HOME}/Library/Application Support/Sublime Text 3/Packages" ]; then
    rm -rf "${HOME}/Library/Application Support/Sublime Text 3/Packages"
fi
mkdir -p "${HOME}/Library/Application Support/Sublime Text 3/Packages"
cd "${HOME}/Library/Application Support/Sublime Text 3/Packages" || exit
echo "Linking Sublime Text packages folders..."
ln -s ~/.dotFiles/Sublime/User .
ln -s ~/.dotFiles/Sublime/OS .

for X in "gitignore_global" "eslintrc" "rubocop.yml" "rspec" "jsbeautifyrc" "stylelintrc.json" "gemrc"; do
        if [ -f ~/.$X ]; then
            rm ~/.$X
        fi
        ln -s ~/.dotFiles/$X ~/.$X
        echo "Linking $X...";
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

git config --global core.excludesfile ~/.gitignore_global

#set zsh as default
chsh -s "$(which zsh)"

if [  ! -d ~/.ssh ] || [ ! -f ~/.ssh/id_rsa ]; then
    echo "Generating RSA keypair - you'll need to enter a passphrase..."
    ssh-keygen -t rsa -b 4096
fi

chmod +x ./.dotFiles/setup_mac.sh

echo "Install and setup complete.  Now run the setup script."