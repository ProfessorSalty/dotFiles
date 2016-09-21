#! /bin/bash
#This script will eventually setup everything

sudo sqlite3 "/Library/Application Support/com.apple.TCC/TCC.db" 'UPDATE access SET allowed = "1";'
#Get the information we need first
echo "Please enter your name (for git config): "
read gitname
echo "Please enter your email (for git config): "
read gitemail

#XCode command line tools
echo "Installing Xcode command line tools..."
xcode-select --install &
pid=$!
sleep 1
osascript <<END
tell application "System Events"
    tell process "Install Command Line Developer Tools"
        keystroke return
        click button "Agree" of window "License Agreement"
    end tell
end tell
END
wait $pid
echo "Done"
#Install Homebrew
echo "Installing Homebrew..."
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
echo "Updating Homebrew..."
brew update
echo "Installing important packages..."
brew install coreutils moreutils findutils tidy-html5 hub gpg-agent mongodb node macvim reattach-to-user-namespace tmux zsh python mas tree
brew install wget --with-iri
brew install brew install vim --override-system-vi
echo "Cleaning up..."
brew cleanup
#Install RVM & Ruby
echo "Installing RVM and Ruby..."
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
wait $!
curl -sSL https://get.rvm.io | bash -s stable --ruby
wait $!
rvm gemset use global
echo "Using gemset $(rvm gemset list)"

#Install globals for Sublime Text plugins
echo "Installing important gems..."
gem install rubocop haml scss_lint rails bundler capistrano

echo "Installing powerline-status..."
pip install powerline-status

git config --global user.name "$gitname"
git config --global user.email "$gitemail"
git config --global credential.helper osxkeychain
#Setup hub to access Github account...?
mkdir -p ~/Projects
cd
echo "Now in $(pwd)"
echo "Cloning dotFiles..."
git clone https://github.com/PortableStick/dotFiles.git ~/.dotFiles
wait $!
mkdir -p ~/Library/Application\ Supprt/Sublime\ Text\ 3/Packages
echo "Linking Sublime Text packages folders..."
ln -s ./dotFiles/Sublime/User ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/
ln -s ./dotFiles/Sublime/OS ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/
for X in gitignore_global eslintrc rubocop.yml rspec jsbeautifyrc stylelintrc.json gemrc; do ln -s ~/.dotFiles/$X .$X; echo "Linking $("$X")..."; done
echo "Linking tmux powerline theme file..."
ln -s ~/.dotFiles/tmux/config/powerline/themes/tmux/default.json ~/.config/powerline/themes/tmux/default.json
echo "Linking tmux.conf..."
ln -s ~/.dotFiles/tmux/tmux.conf ~/.tmux.conf
echo "Linking zshrc..."
ln -s ~/.dotFiles/zsh/zshrc ~/.zshrc
echo "Linking zprofile..."
ln -s ~/.dotFiles/zsh/zprofile ~/.zprofile
git config --global core.excludesfile ~/.gitignore_global

chmod +x ./.dotFiles/setup_mac.sh
echo "Running additional setup..."
sh ~/.dotFiles/setup_mac.sh

#Get other apps
cd ~/Downloads
#Installs Chrome, Firefox, Handbrake, VLC, Transmission, Adium, Dropbox, Sublime Text 3, iterm2, Filezilla, LibreOffice, Audacity, Gimp, 1Password, Alfred, Skim, and Inkscape
echo "Installing other apps..."
curl http://www.getmacapps.com/raw/1mgcplvwiffup | sh
wait $!
mas install 497799835 #xcode
mas install 449589707 #dash
mas install 715768417 #MS remote desktop
sudo sqlite3 "/Library/Application Support/com.apple.TCC/TCC.db" 'UPDATE access SET allowed = "0";'