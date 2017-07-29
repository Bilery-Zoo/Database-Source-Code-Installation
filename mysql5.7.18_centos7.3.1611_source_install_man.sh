###
# create_author: Bilery Zoo(652645572@qq.com)
# create_time  : 2017-07-19
# program      : *_*install MySQL5.7.18 on CentOS7.3.1611 from source code*_*
###


# ①install OS relation
yum install gcc-c++ cmake ncurses-devel


# ②download source code
wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-boost-5.7.18.tar.gz
tar -xzv -f mysql-boost-5.7.18.tar.gz


# ③compile and install
cd mysql-5.7.18/
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/usr/local/mysql/data -DWITH_BOOST=boost
make && make install


# ④init and config
groupadd mysql
useradd -g mysql mysql
mkdir /usr/local/mysql/data
chown -R mysql /usr/local/mysql
chgrp -R mysql /usr/local/mysql

/usr/local/mysql/bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
# [Note] A temporary password is generated for root@localhost: iN+(pF+a_9kp #

/usr/local/mysql/bin/mysql_ssl_rsa_setup --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data

mv /etc/my.cnf /etc/my.cnf.backup
vim /etc/my.cnf

[client]
socket = /tmp/mysql.sock

[mysqld]
socket = /tmp/mysql.sock
basedir = /usr/local/mysql
datadir = /usr/local/mysql/data


# ⑤start up service
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig mysqld on
service mysqld start

ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql

mysql -uroot -p'iN+(pF+a_9kp'
mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY '1024';

firewall-cmd --add-port=3306/tcp --permanent
systemctl restart firewalld.service
vim /etc/my.cnf

[client]
user = root
password = 1024
port = 3306
socket = /tmp/mysql.sock

[root@bilery mysql-5.7.18]# mysql
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 6
Server version: 5.7.18 Source distribution

Copyright (c) 2000, 2017, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> UPDATE `mysql`.`user` SET `Host` = '%' WHERE `User` = 'root';
Query OK, 1 row affected (0.04 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.00 sec)

mysql> 
