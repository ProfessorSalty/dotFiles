#!/usr/bin/env bash

# TODO
# Colorize the output
DOTFILES=$HOME/.dotFiles/
sudo apt-get install -y git aptitude
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

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

#dotNet
if [ -z "$(which dotnet)" ]; then
    sudo sh -c 'echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet-release/ yakkety main" > /etc/apt/sources.list.d/dotnetdev.list'
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 417A0893
fi
#Heroku toolbelt
sudo add-apt-repository "deb https://cli-assets.heroku.com/branches/stable/apt ./"
curl -L https://cli-assets.heroku.com/apt/release.key | sudo apt-key add -
echo *************************************************
#hub
sudo add-apt-repository ppa:cpick/hub -y

sudo aptitude update
# Have to use apt-get here
sudo apt-get install 'dotnet-dev-*'
sudo aptitude install -y hub gnupg tidy gnupg-agent mongodb tmux zsh autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev tree imagemagick shellcheck postgresql postgresql-contrib python-qt4 gcc python-numpy python-scipy python-matplotlib ipython python-pandas python-sympy python-nose mysql-server heroku redis-server redis-tools code tilda python-setuptools python-dev
sudo easy_install pip

git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
git clone https://github.com/nodenv/nodenv.git ~/.nodenv
git clone https://github.com/nodenv/node-build.git ~/.nodenv/plugins/node-build

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
pip install --upgrade virtualenv
pip install ipython[zmq,qtconsole,notebook,test]

echo "Installing NPM modules..."
sudo npm install -g eslint eslint-plugin-babel eslint-plugin-html eslint-plugin-react esformatter esformatter-jsx tern stylelint_d less

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

for FILEPATH in $DOTFILES/zsh/*; do
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
if [ -f $HOME/.config/Code/User/settings.json ]; then
    rm $HOME/.config/Code/User/settings.json
fi
ln -s $DOTFILES/vscode/settings.json $HOME/.config/Code/User/
CODE=$(which code)
if [ -f /usr/local/bin/code ]; then
    rm /usr/local/bin/code
fi
ln -s $CODE /usr/local/bin
ln -s $DOTFILES/backup_vscode.sh /usr/local/bin/backup_vscode

echo "Installing VSCode extensions..."
for X in $(< $DOTFILES/vscode/vscode-extensions.txt); do
    $CODE --install-extension $X
done

# RSA
if [  ! -d ~/.ssh ] || [ ! -f ~/.ssh/id_rsa ]; then
    echo "Generating RSA keypair - you'll need to enter a passphrase..."
    ssh-keygen -t rsa -b 4096
fi

# setup mysql
if [ ! -d /usr/local/var/mysql ]; then
    echo "Setting up MySQL...."
    unset TMPDIR
    mkdir /usr/local/var
    sudo mysql_secure_installation
fi

# set zsh as default
chsh -s "$(which zsh)"
git config --global core.excludesfile ~/.gitignore_global
mkdir -p ~/Projects
chmod +x $DOTFILES/setup_mac.sh $DOTFILES/backup_vscode.sh $DOTFILES/backup_atom.sh $DOTFILES/backup_editors.sh
ln -s $DOTFILES/backup_editors.sh /usr/local/bin/backup_editors
echo "Install and setup complete.  Now run the setup script."

