#!/bin/bash
#mysql 5.6.15 install script
#author: fanqingsong
#data: 2017/10/26

#check user
function check_user(){
	echo "Check user..."
	if [ $(id -u) != "0" ]; then
	  echo "You must be root to run this script!"
		  exit 1
	else 
	  echo "Run script..."
	fi

}

#set install path
function set_path(){
	echo "Please input install path"
	echo "Default path is: /usr/local/mysql"
	read -p "Your install path: " install_path
	if [[ "$install_path" == ""  ]]; then
	  install_path=/usr/local/mysql
	fi
}

#install tools
function install_tools(){
	echo "Install tools..."
	for i in {wget,gcc,gcc-c++,make,autoconf,libtool-ltdl-devel,gd-devel,freetype-devel,libxml2-devel,libjpeg-devel,libpng-devel,openssl-devel,curl-devel,bison,patch,unzip,libmcrypt-devel,libmhash-devel,ncurses-devel,sudo,bzip2,flex,libaio-devel}
	do 
	  yum -y install $i
	done
	echo "Completed!"

}


#install cmake-3.1.1
function install_cmake(){
	echo "Install cmake-3.1.1..."
	if [ ! -f cmake-3.1.1.tar.gz ]; then
	  echo "cmake-3.1.1.tar.gz not exist!"
	  echo "Download file..."
	  wget http://www.cmake.org/files/v3.1/cmake-3.1.1.tar.gz
	fi
	tar zxvf cmake-3.1.1.tar.gz
	cd cmake-3.1.1
	./bootstrap
	make && make install
	echo "Completed!"
}

#install mysql5.6.15
function install_mysql(){
	echo "Install mysql-5.6.16 begin..."
	if [ ! -f mysql-5.6.15.tar.gz ]; then
	  echo "mysql-5.6.15.tar.gz not exist!"
	  echo "Download file..."
	  wget http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.15.tar.gz
	  echo "Completed!"
	fi
	tar zxvf mysql-5.6.15.tar.gz
	cd mysql-5.6.15
	echo "Begin cmake mysql..."
	cmake -DCMAKE_INSTALL_PREFIX=${install_path} -DMYSQL_UNIX_ADDR=/tmp/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_EXTRA_CHARSETS=all -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DWITH_INNODB_MEMCACHED=1 -DWITH_DEBUG=OFF -DWITH_ZLIB=bundled -DENABLED_LOCAL_INFILE=1 -DENABLED_PROFILING=ON -DMYSQL_MAINTAINER_MODE=OFF -DMYSQL_DATADIR=${install_path}/data -DMYSQL_TCP_PORT=3306
	make && make install
	echo "Completed!"
}

#configuring Mysql
function config_mysql(){
	echo "Configuring /etc/my.cnf... "
	/usr/sbin/groupadd mysql
	/usr/sbin/useradd -g mysql mysql
	if [ ! -d "${install_path}/binlog/data_mysql" ]; then
	  mkdir -p ${install_path}/binlog/data_mysql
	fi
	chown -R mysql:mysql ${install_path}
	chown -R mysql:mysql ${install_path}/binlog/data_mysql/

	echo "
	[client]
	port = 3306
	socket = /tmp/mysql.sock
	[mysqld]
	replicate-ignore-db = mysql
	replicate-ignore-db = test
	replicate-ignore-db = information_schema
	user = mysql
	port = 3306
	socket = /tmp/mysql.sock
	basedir = ${install_path}
	datadir = ${install_path}/binlog/data_mysql
	log-error = ${install_path}/mysql_error.log
	pid-file = ${install_path}/mysql.pid
	open_files_limit = 65535
	back_log = 600
	max_connections = 5000
	max_connect_errors = 1000
	table_open_cache = 1024
	external-locking = FALSE
	max_allowed_packet = 32M
	sort_buffer_size = 1M
	join_buffer_size = 1M
	thread_cache_size = 600
#thread_concurrency = 8
	query_cache_size = 128M
	query_cache_limit = 2M
	query_cache_min_res_unit = 2k
	default-storage-engine = MyISAM
	default-tmp-storage-engine=MYISAM
	thread_stack = 192K
	transaction_isolation = READ-COMMITTED
	tmp_table_size = 128M
	max_heap_table_size = 128M
	log-slave-updates
	log-bin = ${install_path}/binlog/binlog
	binlog-do-db=oa_fb
	binlog-ignore-db=mysql
	binlog_cache_size = 4M
	binlog_format = MIXED
	max_binlog_cache_size = 8M
	max_binlog_size = 1G
	relay-log-index = ${install_path}/relaylog/relaylog
	relay-log-info-file = ${install_path}/relaylog/relaylog
	relay-log = ${install_path}/relaylog/relaylog
	expire_logs_days = 10
	key_buffer_size = 256M
	read_buffer_size = 1M
	read_rnd_buffer_size = 16M
	bulk_insert_buffer_size = 64M
	myisam_sort_buffer_size = 128M
	myisam_max_sort_file_size = 10G
	myisam_repair_threads = 1
	myisam_recover
	interactive_timeout = 120
	wait_timeout = 120
	skip-name-resolve
#master-connect-retry = 10
	slave-skip-errors = 1032,1062,126,1114,1146,1048,1396
#master-host = 192.168.1.2
#master-user = username
#master-password = password
#master-port = 3306
	server-id = 1
	loose-innodb-trx=0 
	loose-innodb-locks=0 
	loose-innodb-lock-waits=0 
	loose-innodb-cmp=0 
	loose-innodb-cmp-per-index=0
	loose-innodb-cmp-per-index-reset=0
	loose-innodb-cmp-reset=0 
	loose-innodb-cmpmem=0 
	loose-innodb-cmpmem-reset=0 
	loose-innodb-buffer-page=0 
	loose-innodb-buffer-page-lru=0 
	loose-innodb-buffer-pool-stats=0 
	loose-innodb-metrics=0 
	loose-innodb-ft-default-stopword=0 
	loose-innodb-ft-inserted=0 
	loose-innodb-ft-deleted=0 
	loose-innodb-ft-being-deleted=0 
	loose-innodb-ft-config=0 
	loose-innodb-ft-index-cache=0 
	loose-innodb-ft-index-table=0 
	loose-innodb-sys-tables=0 
	loose-innodb-sys-tablestats=0 
	loose-innodb-sys-indexes=0 
	loose-innodb-sys-columns=0 
	loose-innodb-sys-fields=0 
	loose-innodb-sys-foreign=0 
	loose-innodb-sys-foreign-cols=0

	slow_query_log_file=${install_path}/mysql_slow.log
	long_query_time = 1
	[mysqldump]
	quick
	max_allowed_packet = 32M
	" > /etc/my.cnf
	echo "Completed!"
}

#init database
function init_mysql(){
	echo "Initializing database..."
	cd ${install_path}
	./scripts/mysql_install_db --defaults-file=/etc/my.cnf  --user=mysql
	echo "Completed!"
}

#config auto_run script
function set_boot_script(){
	echo "Create boot scripts..."
	cp ${install_path}/support-files/mysql.server /etc/rc.d/init.d/mysqld
	chkconfig --add mysqld
	chkconfig --level 35 mysqld on
	service mysqld start
	ln -s $install_path/bin/* /usr/bin
	echo "Complete!"
	echo "Install mysql 5.6.15 success!"
}


check_user
set_path
install_tools
install_cmake
install_mysql
config_mysql
init_mysql
set_boot_script

#create myapp database
mysql<<EOF
create database if not exists myapp;
show databases;
exit
EOF
echo -e "Create database myapp Success!"













