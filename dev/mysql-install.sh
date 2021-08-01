#!/bin/sh -xv

yum update -y 

# install mysql on amzon linux
yum install -y https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
amazon-linux-extras install epel -y
yum install -y mysql-community-server
sudo systemctl enable --now mysqld
sudo systemctl status --now mysqld
#sudo grep 'temporary password' /var/log/mysqld.log
#sudo mysql_secure_installation -p'BEw-U?DV,7eO'
#sudo mysql -uroot -p''
#show databases;
#use mysql
#mysql> CREATE USER 'root'@'%' IDENTIFIED BY 'PASSWORD';
#mysql> GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
#mysql> FLUSH PRIVILEGES;
#sudo systemctl restart --now mysqld