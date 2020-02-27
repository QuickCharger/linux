#!/bin/bash

function INSTALL()
{
    dpkg -s $1 > tmp 2>&1
    if grep -q ok tmp; then
        echo "OK ... $1 has installed"
    else
        echo "try install $1" 
        apt-get install $1 -y 1>/dev/null
        echo "OK ... install $1 finished"
    fi  
}

# sudo
if [ "$(whoami)" != "root" ]; then
    echo "please run as root"
    exit
fi

apt update
INSTALL iftop
INSTALL openssh-server
INSTALL vim
INSTALL lrzsz
INSTALL npm
INSTALL subversion
INSTALL net-tools

cd /root

# iftop config
netDevice=`ls /sys/class/net | head -n1`
echo "netDevice=${netDevice}"
if grep -q "iftop" .bashrc; then
    echo "OK ... found alias network in .bashrc\n"
else
    echo "alias network='iftop -n -i ${netDevice} -P'" >> .bashrc
    echo "OK ... add alias network finish\n"
fi

#ssh config
cd /etc/ssh
if [ ! -f "sshd_config.bak" ]; then
	cp sshd_config sshd_config.bak
	sed -i "s/#Port/Port/g" sshd_config
	systemctl enable ssh
else
	echo "sshd has configed. do nothing"
fi

cd /root
if ! grep -q "svnstart" .bashrc; then
    echo "alias svnstart='sudo svnserve -d -r /home/svn --log-file=/var/log/svnserve.log'" >> .bashrc
fi
if ! grep -q "svnstop" .bashrc; then
    echo "alias svnstop='sudo killall svnserve'" >> .bashrc
fi
if ! grep -q "mysql" .bashrc; then
    echo "alias mysql='mysql -uroot -p123456'" >> .bashrc
fi

source .bashrc
