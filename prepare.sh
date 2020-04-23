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

function AddAlias()
{
    fileName=".bashrc"
    if [ -n "$3" ];then
        fileName=$3
    fi

    if grep -q $1 ${fileName}; then
        echo "OK ... found alias $1 in ${fileName}\n"
    else
        echo "alias $1='$2'" >> ${fileName}
        echo "OK ... add alias $1 into ${fileName} finish\n"
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

#ssh config
cd /etc/ssh
if [ ! -f "sshd_config.bak" ]; then
	cp sshd_config sshd_config.bak
	sed -i "s/#Port/Port/g" sshd_config
	systemctl enable ssh
else
	echo "sshd has configed. do nothing"
fi

#alias
cd /root
netDevice=`ls /sys/class/net | head -n1`
echo "netDevice=${netDevice}"
AddAlias network "iftop -n -i ${netDevice} -P"
AddAlias svnstart "sudo svnserve -d -r /home/svn --log-file=/var/log/svnserve.log"
AddAlias svnstop "sudo killall svnserve"
AddAlias mysql "mysql -uroot -p123456"
AddAlias dudu "du -h --max-depth=1"

source .bashrc
