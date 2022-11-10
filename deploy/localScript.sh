sudo apt update
sudo apt install python3.10 -y
python3.10 --version
sudo apt install python3-pip -y
pip -V
sudo apt install ansible -y
ansible --version
sudo apt install openssh-server -y
ssh -v Protocol
sudo apt install virtualbox -y
virtualbox --help
apt-get install wget -y
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install vagrant -y
vagrant --version
sudo mkdir /etc/vbox/
sudo touch /etc/vbox/networks.conf 
sudo echo "* 10.0.0.0/8 192.168.0.0/16" >> /etc/vbox/networks.conf
sudo echo "* 2001::/64" >> /etc/vbox/networks.conf
cat /etc/vbox/networks.conf
sudo apt install docker-compose -y
docker --version
sudo ufw allow 2376/tcp
sudo ufw allow 2377/tcp
sudo ufw allow 7946/tcp
sudo ufw allow 7946/udp
sudo ufw allow 4789/udp
wget --content-disposition https://dl.pstmn.io/download/latest/linux 
tar zxvf postman-linux-x64.tar.gz
sudo apt install ruby-full -y
ruby --version
sudo apt install ruby-bundler -y
bundle --version
sudo mv Postman /opt
sudo ln -s /opt/Postman/Postman /usr/local/bin/postman
echo "[Desktop Entry]" >> /usr/share/applications/postman.desktop
echo "Type=Application" >> /usr/share/applications/postman.desktop
echo "Name=Postman" >> /usr/share/applications/postman.desktop
echo "Icon=/opt/Postman/app/resources/app/assets/icon.png" >> /usr/share/applications/postman.desktop
echo "Exec="/opt/Postman/Postman"" >> /usr/share/applications/postman.desktop
echo "Comment=Postman GUI" >> /usr/share/applications/postman.desktop
echo "Categories=Development;Code;" >> /usr/share/applications/postman.desktop
cat ~/.ssh/id_rsa.pub
