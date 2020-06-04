#!/usr/bin/env bash
# author    : Bilery Zoo(bilery.zoo@gmail.com)
# create_ts : 2020-02-02
# program   : install & init & launch MySQL V-5.7.26-linux-glibc


# *******************************************************************************
#
#            　　 　 　　　　 　 |＼＿/|
#            　　 　 　　　　 　 | ・x・ |
#            　　 ＼＿＿＿＿＿／　　　 |
#            　　 　 |　　　 　　　　　|    ニャンー ニャンー
#            　　　　＼　　　　　 　ノ　
#            　（（（　(/￣￣￣￣(/ヽ)
#
# User-definition Variables Area
#
server=${2:-1024}
port=${3:-3306}
root_password=${4:-1024}
directory_install=${5:-/usr/local}
host=${6:-$(ip address | grep -E '([[:digit:]]{1,3}[.]){3}([[:digit:]]{1,3})' | grep -v '127.0.0.1' | awk '{ print $2 }' | awk -F / '{ print $1 }')}
#
# *******************************************************************************


my_cnf=/etc/my${port}.cnf

directory_base=${directory_install}/mysql
directory_storage=/db/mysql/${port}
directory_tmp=${directory_storage}/tmp
directory_data=${directory_storage}/data
directory_log_bin=${directory_data}/binary-log-bin
directory_relay_log=${directory_data}/relay-log-bin

file_socket=${directory_storage}/mysql${port}.sock
file_pid=${directory_data}/pid_file${port}.pid
file_error=${directory_data}/error_log${port}.err
file_log_bin_index=${directory_data}/binary-log-bin.index
file_master_info=${directory_data}/master.info
file_relay_log_index=${directory_data}/relay-log-bin.index
file_relay_log_info=${directory_data}/relay-log.info


function usage_program() {
    echo -e '\nProgram can get up to 6 valid args(the rest is ignored) from command line.'
    echo "* Input blank string('' or \"\") as placeholder when an arg takes default value and with args of defined values following *"
    echo ''
    echo -e "\t\$1 -> Operation options: pass in \`option\` to see detail. No default value."
	echo -e "\t\$2 -> Value passed to MySQL system variable \`server-id\`. Default value: ${server}."
	echo -e "\t\$3 -> Connection port of this MySQL instance. Default value: ${port}."
	echo -e "\t\$4 -> Root account password to change to. Default value: ${root_password}."
	echo -e "\t\$5 -> MySQL installing father directory. Default value: ${directory_install}."
	echo -e "\t\$6 -> Value passed to MySQL system variable \`report_host\`. Default value: ${host}."
}


function usage_option() {
	echo 'Get invalid option, please input numeric codes below(as to "$1"):'
	echo ''
	echo -e '\t0 -> Only install OS dependencies, download MySQL package, unzip it and do some launching preparisons'
	echo -e '\t1 -> Only init mysqld and launch a MySQL instance(relay on Option 0 finished)'
	echo -e '\t2 -> Full service(Option 0 + Option 1)'
	echo -e '\t3 -> Alter init root password'
}


function create_cnf_file() {
    local my_cnf=${my_cnf}
    if [ ! -e ${my_cnf} ]; then
    (
        cat << EOF
[client]

port = ${port}
socket = ${file_socket}

default-character-set = utf8mb4

[mysql]

port = ${port}
socket = ${file_socket}

[mysqld]

basedir = ${directory_base}
tmpdir = ${directory_tmp}
datadir = ${directory_data}
socket = ${file_socket}
pid-file = ${file_pid}
log_error = ${file_error}

# (￣_,￣ ) #
character_set_server = utf8mb4
character-set-client-handshake = ON
collation_server = utf8mb4_general_ci
max_connections = 151
max_user_connections = 0
max_connect_errors = 100
wait_timeout = 28800
interactive_timeout = 28800
max_allowed_packet = 1G
tmp_table_size = 16M
max_heap_table_size = 16M
binlog_cache_size = 32K

skip_name_resolve = ON
lower_case_table_names = 1
sql_mode = STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
explicit_defaults_for_timestamp = ON
log_error_verbosity = 3

# innidb general config
default-storage-engine = InnoDB
# (￣_,￣ ) #
innodb_buffer_pool_size = 2G
innodb_buffer_pool_instances = 2
innodb_log_buffer_size = 16M
innodb_read_io_threads = 4
innodb_write_io_threads = 4
innodb_page_cleaners = 2
innodb_purge_threads = 1
innodb_io_capacity = 200

innodb_file_per_table = ON
innodb_data_file_path = ibdata0:1G;ibdata1:1G;ibdata2:1G:autoextend
innodb_log_group_home_dir = ./
innodb_log_files_in_group = 3
innodb_log_file_size = 2G

innodb_stats_persistent = ON
innodb_stats_on_metadata = OFF
innodb_large_prefix = ON
innodb_thread_concurrency = 0
innodb_flush_method = O_DIRECT
innodb_use_native_aio = ON

# innidb & replication & HA config
sync_binlog = 1
innodb_support_xa = ON
innodb_flush_log_at_trx_commit = 1

# (￣_,￣ ) #
server-id = ${server}
report-port = ${port}
report-host = ${host}
expire_logs_days = 30
skip-slave-start = ON
relay_log_purge = ON
binlog_format = row
log-slave-updates = ON
log-bin = ${directory_log_bin}
log_bin_index = ${file_log_bin_index}
master-info-file = ${file_master_info}
relay_log = ${directory_relay_log}
relay_log_index = ${file_relay_log_index}
relay_log_info_file = ${file_relay_log_info}
binlog-ignore-db = sys
binlog-ignore-db = information_schema
binlog-ignore-db = performance_schema

gtid_mode = ON
enforce_gtid_consistency = 1
slave_skip_errors = 1062,1146

EOF
    ) > ${my_cnf}
    else
        echo "Option file @@${my_cnf} exists and skips create"
        return 0
    fi
    if [ $? -eq 0 ]; then
        echo "Create option file @@${my_cnf} success"
        return 0
    else
        echo "Create option file @@${my_cnf} failed"
        exit 1
    fi
}


function prepare_mysql_install() {
    yum -y install gcc-c++ cmake ncurses-devel libaio > /dev/null 2>&1
    if [ ! -e mysql-5.7.26-linux-glibc2.12-x86_64.tar.gz ]; then
        wget https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-5.7.26-linux-glibc2.12-x86_64.tar.gz > /dev/null 2>&1
    fi
    if [ $? -eq 0 ]; then
        if [ ! -d ${directory_base} ]; then
            tar -xzf mysql-5.7.26-linux-glibc2.12-x86_64.tar.gz -C ${directory_install} > /dev/null 2>&1 &&
            mv ${directory_install}/mysql-5.7.26-linux-glibc2.12-x86_64/ ${directory_base}
        fi
    else
        echo "Download MySQL source package failed"
        exit 1
    fi
    if [ $? -eq 0 ]; then
        grep mysql /etc/group > /dev/null
    else
        echo "Prepare MySQL base directory failed"
        exit 1
    fi
    if [ $? -eq 1 ]; then
        groupadd mysql
    fi
    if [ $? -eq 0 ]; then
        grep mysql /etc/passwd > /dev/null
    else
        echo "Add mysql os group failed"
        exit 1
    fi
    if [ $? -eq 1 ]; then
        useradd -g mysql mysql
    fi
    if [ $? -eq 0 ]; then
        if [ -e /etc/my.cnf ]; then
            mv /etc/my.cnf /etc/my.cnf.default
        fi
    else
        echo "Add mysql os user failed"
        exit 1
    fi
    grep "${directory_base}/bin" /etc/profile > /dev/null
    if [ $? -eq 1 ]; then
        echo -e "# MySQL PATH\nexport PATH=${directory_base}/bin:$PATH\n" >> /etc/profile && source /etc/profile
    fi
    if [ $? -eq 0 ]; then
        echo "Prepare MySQL install @@${directory_base} success"
        return 0
    else
        echo "Prepare MySQL install @@${directory_base} failed"
        exit 1
    fi
}


function launch_mysql_service() {
    mkdir -p ${directory_tmp} ${directory_data}
    chown -R mysql:mysql ${directory_storage}
    mysqld --defaults-file=${my_cnf} --initialize
    if [ $? -eq 0 ]; then
        echo "Init mysqld program @@${directory_storage} success"
    else
        echo "Init mysqld program @@${directory_storage} failed"
        exit 1
    fi
    chown -R mysql:mysql ${directory_storage}
    mysqld_safe --defaults-file=${my_cnf} --socket=${file_socket} --port=${port} --user=mysql > /dev/null 2>&1 &
    ps aux | grep mysqld | grep -v grep > /dev/null
    if [ $? -eq 0 ]; then
        echo "Launch MySQL service @@${directory_storage} success"
    else
        echo "Launch MySQL service @@${directory_storage} failed"
        exit 1
    fi
}


function change_root_password() {
    init_password=$(grep password ${file_error} | awk '{ print $NF }' | sed -ne '1p')
    mysql --socket=${file_socket} --port=${port} --user=root --password="${init_password}" --execute="ALTER USER 'root'@'localhost' IDENTIFIED BY '${root_password}'" --connect-expired-password
    if [ $? -eq 0 ]; then
        echo "Change user password 'root'@'localhost' success"
        return 0
    else
        echo "Change user password 'root'@'localhost' failed"
        exit 1
    fi
}


function main() {
	if [ -z $1 ]; then
		usage_program
		exit 127
	fi
    case $1 in
	-h|--help)
		usage_program
		exit 0
		;;
	option)
		usage_option
		exit 0
		;;
    0)
        prepare_mysql_install
        ;;
    1)
        create_cnf_file && launch_mysql_service
        ;;
    2)
        prepare_mysql_install && create_cnf_file && launch_mysql_service
        ;;
    3)
        change_root_password
        ;;
    *)
		usage_option
        exit 127
    esac
}


main "$1"

