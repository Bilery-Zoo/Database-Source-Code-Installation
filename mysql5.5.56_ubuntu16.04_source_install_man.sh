###
# create_author: Bilery Zoo(652645572@qq.com)
# create_time  : 2017-07-18
# program      : *_*install MySQL5.5.56 on Ubuntu16.04LTS from source code(for history release study)*_*
###


# ①install OS relation
apt install cmake bison libncurses5-dev


# ②download source code
wget https://dev.mysql.com/get/Downloads/MySQL-5.5/mysql-5.5.56.tar.gz
tar -xzv -f mysql-5.5.56.tar.gz


# ③compile and install
cd mysql-5.5.56/
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/usr/local/mysql/data
make && make install


# ④init and config
groupadd mysql
useradd -g mysql mysql
chown -R mysql /usr/local/mysql
chgrp -R mysql /usr/local/mysql

cd /usr/local/mysql/
scripts/mysql_install_db --user=mysql

cp support-files/my-medium.cnf /etc/my.cnf


# ⑤start up service
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
update-rc.d mysqld defaults
service mysqld start

./bin/mysqladmin -uroot password '1024'
ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql

root@ubuntu:/usr/local/mysql# mysql -uroot -p1024
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 4
Server version: 5.5.56-log Source distribution

Copyright (c) 2000, 2017, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> CREATE USER 'root'@'%' IDENTIFIED BY '1024';
Query OK, 0 rows affected (0.00 sec)

mysql> GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '1024';
Query OK, 0 rows affected (0.00 sec)

mysql> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.00 sec)

mysql> 

vim /etc/my.cnf

[client]
user = root
password = 1024
port = 3306
socket = /tmp/mysql.sock
