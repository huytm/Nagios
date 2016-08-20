#!/bin/bash

#This Script will install Nagios server with nagios 2.4.11
#Author HuyTM
date=`date +%Y%m%d`
home_dir=`mkdir -p /tmp/nagios_install_$date`
ip_server=`ip addr show | grep inet | grep -v "inet6"| grep -v "127.0.0.1/8" | awk '{print $2;}'|sed 's/\/.*$//' | head -n 1 `


#Install some requied packages
echo " ------- Install requied packages --------"
sleep 3
yum install -y httpd php gcc glibc glibc-common gd gd-devel make net-snmp openssl-devel unzip wget

sleep 5
check=`rpm -q httpd php gcc glibc glibc-common gd gd-devel make net-snmp openssl-devel unzip wget | grep "is not installed" | wc -l`
if [ $check -ne 0 ]
        then
			echo "Some packages must be installed for Nagios Please check !!!" ; exit
        else
			useradd nagios
			groupadd nagcmd
			usermod -G nagcmd nagios
			usermod -G nagcmd apache
			cd $home_dir
			wget https://www.nagios-plugins.org/download/nagios-plugins-2.1.2.tar.gz
			wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.1.1.tar.gz
			wget http://pkgs.fedoraproject.org/repo/pkgs/nrpe/nrpe-2.15.tar.gz/3921ddc598312983f604541784b35a50/nrpe-2.15.tar.gz
			sleep 3
			tar xzf nagios-plugins-2.1.2.tar.gz
			tar xzf nagios-4.1.1.tar.gz
			tar xzf nrpe-2.15.tar.gz
			# Install nagios core
			sleep 3
			cd nagios-4.1.1
	        ./configure --with-command-group=nagcmd
			make all
            make install
            make install-init
			make install-commandmode
	        make install-config
            make install-webconf
			# Install Nagios plugin
			sleep 3
			cd -
			cd nagios-plugins-2.1.2
			./configure --with-nagios-user=nagios --with-nagios-group=nagios
			make
			make install
			#Install nrpe daemon and nrpe plugin
			sleep 3
			cd -
			cd nrpe-2.15
			./configure
			make all
			make install-daemon
			make install-plugin
			#Add user
			htpasswd -b -s -c /usr/local/nagios/etc/htpasswd.users nagiosadmin nagiosadmin
			htpasswd -b -s /usr/local/nagios/etc/htpasswd.users nagiosviewer nagiosviewer
			echo "authorized_for_all_services=nagiosviewer" >> /usr/local/nagios/etc/cgi.cfg
			echo "authorized_for_all_hosts=nagiosviewer" >> /usr/local/nagios/etc/cgi.cfg
			#Start nagios
			chkconfig --add nagios
			chkconfig --level 35 nagios on
			chkconfig --add httpd
			chkconfig --level 35 httpd on
			service httpd start
			service httpd restart
			service nagios start
			service nagios restart
			## Finish
echo "------------------------------------------------------------"
echo "| Finish install Nagios                                    |"
echo "| You can access to nagios server at: $ip_server/nagios    |"
echo "| With admin user: nagiosadmin/nagiosadmin                 |"
echo "| With onlyview user: nagiosviewer/nagiosviewer            |"
echo "------------------------------------------------------------"
fi 		

rm -rf $home_dir
