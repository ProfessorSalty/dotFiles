#! /bin/bash

sudo apt install xrdp
sudo apt remove speech-dispatcher pulseaudio

ufw allow 32421
ufw allow 51413
ufw allow 9091
ufw allow 55455
ufw allow from any port 32421 to any port 389 proto tcp
ufw allow 32400/tcp
ufw allow out 32400/tcp
ufw allow 1900/udp
ufw allow out 1900/udp
ufw allow 5353/udp
ufw allow 137,138/udp
ufw allow 139,445/tcp
ufw allow 631
ufw allow 3389
ufw allow 1022
ufw allow 32469
ufw allow 32410
ufw allow 32412
ufw allow 32413
ufw allow 32414

# Plex install
wget -O - http://shell.ninthgate.se/packages/shell.ninthgate.se.gpg.key | sudo apt-key add -
echo "deb http://shell.ninthgate.se/packages/debian jessie main" | sudo tee -a /etc/apt/sources.list.d/plex.list
sudo apt update
sudo apt install plexmediaserver -y