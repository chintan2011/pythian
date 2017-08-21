#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

#updating machine to most recent
apt-get update -y 2> /dev/null

#adding user pythian and creating folder for git code
useradd pythian
install -d -o pythian -g pythian -m 0750 /opt/code

#function for creating symlink for nginx configuration file
nginx_conf (){
	if [ ! -d /var/www ];then
		sudo rm -Rf /var/www
	echo "create symlinks to the vagrant folder"
		ln -s /vagrant /usr/share/nginx/www
		ln -s /vagrant /var/www
	fi
}
#using nginx as web server and checking if installed or not
if [ $(dpkg-query -W -f='${Status}' nginx 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
  echo "nginx... Not Installed!"
  echo "Installing nginx...please wait"
  apt-get install -y nginx 2> /dev/null
  echo "Starting nginx web server"
  service nginx start
  #testing nginx config
  nginx -t
  nginx_conf
  
else
	echo "nginx... Installed"
	echo "starting nginx web server"
	service nginx start
  #testing nginx config
  nginx -t
  nginx_conf

fi

#git repository installing and cloning an existing repo to /opt/code folder
if [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
  echo "git... Not Installed!"
  echo "Installing git...please wait"
  apt-get install -y git 2> /dev/null
  echo "Cloning tomwhickey's git repository to /opt/code"
  git clone https://github.com/tomwhickey/pythian.git /opt/code/

  else
	echo "git... Installed"
	echo "Cloning tomwhickey's git repository to /opt/code"
	git clone https://github.com/tomwhickey/pythian.git /opt/code/
	echo "creating symlink for git repo /opt/code to /vagrant"
fi

# mysql server installing
if [ $(dpkg-query -W -f='${Status}' mysql-server 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
  echo "mysql... Not Installed!"
  echo "Installing mysql...please wait"
  wget https://dev.mysql.com/get/mysql-apt-config_0.8.7-1_all.deb
	echo mysql-apt-config mysql-apt-config/repo-distro select ubuntu | debconf-set-selections
	echo mysql-apt-config mysql-apt-config/repo-codename select trusty | debconf-set-selections
	echo mysql-apt-config mysql-apt-config/select-server select mysql-5.7 | debconf-set-selections
	echo mysql-community-server mysql-community-server/root-pass password vagrant | debconf-set-selections
	echo mysql-community-server mysql-community-server/re-root-pass password vagrant | debconf-set-selections
	echo "configuring environment before installation...please wait"
	dpkg -i mysql-apt-config_0.8.7-1_all.deb > /dev/null
    apt-get install -y mysql-server 2> /dev/null
	#testing mysql version
	mysqladmin version
  else
	echo "mysql... Installed"
	echo "starting mysql server"
	service mysql start
	#tsting mysql version
	mysqladmin version
fi
