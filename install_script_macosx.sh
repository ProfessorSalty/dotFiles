#! /bin/bash
#This script will eventually setup everything

#Make sure we don't get blocked by xcode license
sudo xcodebuild -license accept
#Get the information we need first
echo "Please enter your name (for git config): "
read gitname
echo "Please enter your email (for git config): "
read gitemail

#Install Homebrew
echo "Installing Homebrew..."
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
echo "Updating Homebrew..."
brew update
echo "Installing important packages..."
brew install coreutils moreutils findutils tidy-html5 hub gpg-agent mongodb node macvim reattach-to-user-namespace tmux zsh python tree rbenv
brew install wget --with-iri
brew install vim --override-system-vi
echo "Cleaning up..."
brew cleanup

#get oh-my-zsh
echo "Installing oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo "Initializing rbenv..."
rbenv init
rubyversion=$(rbenv install -l | grep -v - | tail -1)
echo "Downloading Ruby $rubyversion..."
rbenv install $rubyversion
rbenv global $rubyversion


#dotNet
mkdir -p /usr/local/lib
ln -s /usr/local/opt/openssl/lib/libcrypto.1.0.0.dylib /usr/local/lib/
ln -s /usr/local/opt/openssl/lib/libssl.1.0.0.dylib /usr/local/lib/
echo "Downloading dotNet Core to $(~/Downloads)..."
wget -O ~/Downloads/dotnet.pkg https://go.microsoft.com/fwlink/?LinkID=835011
echo "Installing dotNet Core..."
sudo installer -pkg ~/Downloads/dotnet.pkg -target /

#Install globals for Sublime Text plugins
echo "Installing important gems..."
gem install rubocop haml scss_lint rails bundler capistrano tmuxinator

echo "Installing powerline-status..."
pip install powerline-status
git clone https://github.com/powerline/fonts.git ~/Downloads/powerline-fonts
cd ~/Downloads/powerline-fonts
chmod +x ./install.sh
sh ./install.sh
# cd
# rm -rf ~/Downloads/powerline-fonts

git config --global user.name "$gitname"
git config --global user.email "$gitemail"
git config --global credential.helper osxkeychain
#Setup hub to access Github account...?
mkdir -p ~/Projects
echo "Now in $(pwd)"
#should clone dotFiles repo only if ~/.dotFiles does not exist
if [ ! -d ~/.dotFiles ]; then
	echo "Cloning dotFiles..."
	git clone https://github.com/PortableStick/dotFiles.git ~/.dotFiles
	wait $!
fi

if [ -d "${HOME}/Library/Application Support/Sublime Text 3/Packages" ]; then
    rm -rf "${HOME}/Library/Application Support/Sublime Text 3/Packages"
fi
mkdir -p "${HOME}/Library/Application Support/Sublime Text 3/Packages"
cd "${HOME}/Library/Application Support/Sublime Text 3/Packages"
echo "Linking Sublime Text packages folders..."
ln -s ~/.dotFiles/Sublime/User .
ln -s ~/.dotFiles/Sublime/OS .
cd

for X in "gitignore_global" "eslintrc" "rubocop.yml" "rspec" "jsbeautifyrc" "stylelintrc.json" "gemrc"; do ln -s ~/.dotFiles/$X ~/.$X; echo "Linking $X..."; done
echo "Linking tmux powerline theme file..."
mkdir -p ~/.config/powerline/themes/tmux
ln -s ~/.dotFiles/tmux/config/powerline/themes/tmux/default.json ~/.config/powerline/themes/tmux/default.json
echo "Linking tmux.conf..."
ln -s ~/.dotFiles/tmux/tmux.conf ~/.tmux.conf
echo "Linking zshrc..."
rm ~/.zshrc
ln -s ~/.dotFiles/zsh/zshrc ~/.zshrc
echo "Linking zprofile..."
ln -s ~/.dotFiles/zsh/zprofile ~/.zprofile
git config --global core.excludesfile ~/.gitignore_global

#set zsh as default
chsh -s $(which zsh)

chmod +x ./.dotFiles/setup_mac.sh
echo "Running additional setup..."
# sh ~/.dotFiles/setup_mac.sh

rbenv shell $rubyversion
echo "Install and setup complete.  Please log out and log in again."