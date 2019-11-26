###
# create_author: Bilery Zoo(652645572@qq.com)
# create_time  : 2019-10-24
# program      : *_*install MySQL8.0.18 on Ubuntu18.04LTS from source code*_*
###


# ①install OS relation
apt install build-essential cmake bison libncurses5-dev libssl-dev pkg-config


# ②download source code
wget https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-boost-8.0.18.tar.gz
tar xzv -f mysql-boost-8.0.18.tar.gz
cd mysql-8.0.18/ ; ls


# ③compile and install
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/usr/local/mysql/data -DWITH_BOOST=boost -DFORCE_INSOURCE_BUILD=ON
make && make install


# ④init and config
groupadd mysql
useradd -g mysql mysql
mkdir -p /usr/local/mysql/data
chown -R mysql:mysql /usr/local/mysql

/usr/local/mysql/bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
# [Server] A temporary password is generated for root@localhost: qiesSMa9FI)% #

/usr/local/mysql/bin/mysql_ssl_rsa_setup --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data

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
update-rc.d mysqld defaults
service mysqld start
echo -e '# MySQL PATH\nexport PATH=/usr/local/mysql/bin:$PATH\n' >> /etc/profile
source /etc/profile

mysql -uroot -p'qiesSMa9FI)%'
mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY '1024';

vim /etc/my.cnf

[client]
user = root
password = 1024
port = 3306
socket = /tmp/mysql.sock


root@ubuntu:~/mysql-8.0.18# mysql
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 9
Server version: 8.0.18 Source distribution

Copyright (c) 2000, 2019, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> UPDATE `mysql`.`user` SET `Host` = '%' WHERE `User` = 'root';
Query OK, 1 row affected (0.01 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.02 sec)

mysql> 

