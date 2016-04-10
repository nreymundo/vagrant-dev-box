#!/bin/sh
#=========================================================

#=========================================================
#echo "Forcing encoding to UTF-8..."
#=========================================================

#sudo echo “LANG=en_US.UTF-8” >> /etc/environment
#sudo echo “LANGUAGE=en_US.UTF-8” >> /etc/environment
#sudo echo “LC_ALL=en_US.UTF-8” >> /etc/environment
#sudo echo “LC_CTYPE=en_US.UTF-8” >> /etc/environment

#=========================================================
echo "Install Java 8 + necessary software"
#=========================================================
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
sudo apt-get -y upgrade
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get -y install oracle-java8-installer

apps='vim git-core rungetty firefox openvpn unzip gitg'
desktop='i3 xorg'
sudo apt-get update
sudo apt-get -y install $apps $desktop

#=========================================================
echo "Copying i3 settings to the guest machine..."
#=========================================================
cp -r /vagrant/configFiles/.i3 /home/vagrant/
chown -R vagrant:vagrant /home/vagrant/.i3

#=========================================================
echo "Creating useful git settings..."
#=========================================================
wget 'https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh' -O .git-prompt.sh
chown vagrant:vagrant .git-prompt.sh
#echo "source ~/.git-prompt.sh" >> /home/vagrant/.bashrc
#echo "PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[01;34m\] \w\[\033[00m\]$(__git_ps1) \$ '" >> /home/vagrant/.bashrc
sudo cp /vagrant/configFiles/.bashrc /home/vagrant/.bashrc
chown vagrant:vagrant /home/vagrant/.bashrc

cp /vagrant/configFiles/.gitconfig /home/vagrant/.gitconfig
chown vagrant:vagrant /home/vagrant/.gitconfig

#=========================================================
echo "Installing maven..."
#=========================================================
MAVEN_DIR=apache-maven-3.3.9
MAVEN_FILE=${MAVEN_DIR}-bin.tar.gz
wget "http://mirrors.nxnethosting.com/apache/maven/maven-3/3.3.9/binaries/${MAVEN_FILE}"
tar -xf ${MAVEN_FILE}
mv ${MAVEN_DIR} maven3
chown -R vagrant:vagrant maven3
echo 'export M2_HOME=/home/vagrant/maven3' >> /home/vagrant/.bashrc
rm ${MAVEN_FILE}

#=========================================================
echo "Downloading and extracting Java 7..."
#=========================================================
curl -L --cookie "oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u65-b17/jdk-7u65-linux-x64.tar.gz -o jdk-7-linux-x64.tar.gz
tar -xvf jdk-7-linux-x64.tar.gz
sudo mkdir -p /usr/lib/jvm
sudo mv ./jdk1.7.* /usr/lib/jvm/
rm jdk-7-linux-x64.tar.gz

#=========================================================
echo "Installing Intellij IDEA..."
#=========================================================
#Downloads the latest Community Edition or Ultimate version using a script from
#https://github.com/folkswithhats/fedy-plugins-developers/

#Downloads the script to install the Ultimate Edition.
#wget "https://raw.githubusercontent.com/folkswithhats/fedy-plugins-developers/master/intellijideaultimate.plugin/install.sh" -O installIdea.sh

#Downloads the script to install the Community Edition.
wget "https://raw.githubusercontent.com/folkswithhats/fedy-plugins-developers/master/intellijideacommunity.plugin/install.sh" -O installIdea.sh

chmod +x installIdea.sh
sudo ./installIdea.sh
rm installIdea.sh

#Copy a set of default configs to the home directory.
#If it doesn't pick it right away just tell it to load it from here on first run.
cp -r /vagrant/configFiles/.IdeaIC2016.1 /home/vagrant/
chown -R vagrant:vagrant /home/vagrant/.IdeaIC2016.1

#=========================================================
echo "Updating user path in .bashrc..."
#=========================================================
echo 'export PATH=$M2_HOME/bin:$PATH' >> /home/vagrant/.bashrc

#=========================================================
echo "Set autologin for the Vagrant user..."
#=========================================================
sudo sed -i '$ d' /etc/init/tty1.conf
sudo echo "exec /sbin/rungetty --autologin vagrant tty1" >> /etc/init/tty1.conf

#=========================================================
echo -n "Start X on login..."
#=========================================================
PROFILE_STRING=$(cat <<EOF
if [ ! -e "/tmp/.X0-lock" ] ; then
    startx
fi
EOF
)
echo "${PROFILE_STRING}" >> .profile
echo "ok"

#=========================================================
echo "Download the latest chrome..."
#=========================================================
wget "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo rm google-chrome-stable_current_amd64.deb
sudo apt-get install -y -f

#=========================================================
echo "Download latest selenium server..."
#=========================================================
SELENIUM_VERSION=$(curl "https://selenium-release.storage.googleapis.com/" | perl -n -e'/.*<Key>([^>]+selenium-server-standalone[^<]+)/ && print $1')
wget "https://selenium-release.storage.googleapis.com/${SELENIUM_VERSION}" -O selenium-server-standalone.jar
chown vagrant:vagrant selenium-server-standalone.jar

#=========================================================
echo "Download latest chrome driver..."
#=========================================================
CHROMEDRIVER_VERSION=$(curl "http://chromedriver.storage.googleapis.com/LATEST_RELEASE")
wget "http://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip"
unzip chromedriver_linux64.zip
sudo rm chromedriver_linux64.zip
chown vagrant:vagrant chromedriver

#=========================================================
echo -n "Install tmux scripts..."
#=========================================================
TMUX_SCRIPT=$(cat <<EOF
#!/bin/sh
tmux start-server

tmux new-session -d -s selenium
tmux send-keys -t selenium:0 './chromedriver' C-m

tmux new-session -d -s chrome-driver
tmux send-keys -t chrome-driver:0 'java -jar selenium-server-standalone.jar' C-m
EOF
)
echo "${TMUX_SCRIPT}"
echo "${TMUX_SCRIPT}" > tmux.sh
chmod +x tmux.sh
chown vagrant:vagrant tmux.sh
echo "ok"

#=========================================================
echo -n "Install startup scripts..."
#=========================================================
STARTUP_SCRIPT=$(cat <<EOF
#!/bin/sh
~/tmux.sh &
xterm &
EOF
)
echo "${STARTUP_SCRIPT}" > /etc/X11/Xsession.d/9999-common_start
chmod +x /etc/X11/Xsession.d/9999-common_start
echo "ok"

#=========================================================
echo -n "Add host alias..."
#=========================================================
echo "192.168.33.1 host" >> /etc/hosts
echo "ok"

#=========================================================
echo -n "Cleaning up..."
#=========================================================
apt-get -y autoremove
apt-get -y clean

#=========================================================
echo "Rebooting the VM..."
#=========================================================
sudo reboot
