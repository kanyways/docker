#!/bin/bash

SHELL_FOLDER=$(cd $(dirname $0);pwd)

stop_redis(){
	cd $SHELL_FOLDER
	docker-compose down
}

init_dir(){
	cd $SHELL_FOLDER;
	rm -rf ./redis/
	# 创建文件夹
	mkdir -p ./redis/nodes-6379/{conf,data}
	mkdir -p ./redis/nodes-6380/{conf,data}
	mkdir -p ./redis/nodes-6381/{conf,data}

	mkdir -p ./redis/sentinel-26379/{conf,data}
	mkdir -p ./redis/sentinel-26380/{conf,data}
	mkdir -p ./redis/sentinel-26381/{conf,data}
}

init_conf(){

	read -p "请输入Redis密码：" PASSWORD
	read -p "请输入本地对外Ip：" REMOTEADDRESS
	read -p "请输入有几个从库：" SlaveNum

	cd $SHELL_FOLDER
	cp redis.conf ./redis/nodes-6379/conf/
	cd $SHELL_FOLDER/redis/nodes-6379/conf/
	
	sudo sed  -i "s/bind 127.0.0.1/# bind 127.0.0.1/g" redis.conf
	sudo sed  -i "s/appendonly no/appendonly yes/g" redis.conf
	sudo sed  -i "s/# # bind 127.0.0.1 ::1/# bind 127.0.0.1 ::1/g" redis.conf
	sudo sed  -i "s/logfile \"\"/logfile \"redis.log\"/g" redis.conf
	sudo sed  -i "s/notify-keyspace-events \"\"/notify-keyspace-events Ex/g" redis.conf
	sudo sed  -i "s/# requirepass foobared/# requirepass foobared\nrequirepass $PASSWORD/g" redis.conf
	sudo sed  -i "s/# masterauth <master-password>/# masterauth <master-password>\nmasterauth $PASSWORD/g" redis.conf

	cp $SHELL_FOLDER/redis/nodes-6379/conf/redis.conf $SHELL_FOLDER/redis/nodes-6380/conf/
	cp $SHELL_FOLDER/redis/nodes-6379/conf/redis.conf $SHELL_FOLDER/redis/nodes-6381/conf/

	# 配置Redis端口
	
	sed -i '/# If port 0 is specified Redis will not listen on a TCP socket\./{:a;n;s/port 6379/# port 6379\nport 6379/g;/# TCP listen() backlog\./!ba}' $SHELL_FOLDER/redis/nodes-6379/conf/redis.conf
	sed -i '/# If port 0 is specified Redis will not listen on a TCP socket\./{:a;n;s/port 6379/# port 6379\nport 6380/g;/# TCP listen() backlog\./!ba}' $SHELL_FOLDER/redis/nodes-6380/conf/redis.conf
	sed -i '/# If port 0 is specified Redis will not listen on a TCP socket\./{:a;n;s/port 6379/# port 6379\nport 6381/g;/# TCP listen() backlog\./!ba}' $SHELL_FOLDER/redis/nodes-6381/conf/redis.conf

	# 配置 Sentinel 文件

	cd $SHELL_FOLDER
	cp sentinel.conf ./redis/sentinel-26379/conf/
	cd $SHELL_FOLDER/redis/sentinel-26379/conf/

	# 修改通用 Sentinel 配置

	sudo sed  -i "s/sentinel monitor mymaster 127.0.0.1 6379 2/# sentinel monitor mymaster 127.0.0.1 6379 2\nsentinel monitor mymaster $REMOTEADDRESS 6379 $SlaveNum/g" sentinel.conf
	sudo sed  -i "s/# sentinel announce-ip 1.2.3.4/# sentinel announce-ip 1.2.3.4\nsentinel announce-ip $REMOTEADDRESS/g" sentinel.conf
	sudo sed  -i "s/# sentinel auth-pass mymaster MySUPER--secret-0123passw0rd/# sentinel auth-pass mymaster MySUPER--secret-0123passw0rd\nsentinel auth-pass mymaster $PASSWORD/g" sentinel.conf
	
	# 复制配置文件
	
	cp $SHELL_FOLDER/redis/sentinel-26379/conf/sentinel.conf $SHELL_FOLDER/redis/sentinel-26380/conf/
	cp $SHELL_FOLDER/redis/sentinel-26379/conf/sentinel.conf $SHELL_FOLDER/redis/sentinel-26381/conf/

	# 修改端口

	sudo sed  -i "s/port 26379/# port 26379\nport 26379/g" $SHELL_FOLDER/redis/sentinel-26379/conf/sentinel.conf
	sudo sed  -i "s/port 26379/# port 26379\nport 26380/g" $SHELL_FOLDER/redis/sentinel-26380/conf/sentinel.conf
	sudo sed  -i "s/port 26379/# port 26379\nport 26381/g" $SHELL_FOLDER/redis/sentinel-26381/conf/sentinel.conf
	sudo sed  -i "s/# sentinel announce-ip 1.2.3.4/# sentinel announce-ip 1.2.3.4\nsentinel announce-port 26379/g" sentinel.conf
	sudo sed  -i "s/# sentinel announce-ip 1.2.3.4/# sentinel announce-ip 1.2.3.4\nsentinel announce-port 26380/g" sentinel.conf
	sudo sed  -i "s/# sentinel announce-ip 1.2.3.4/# sentinel announce-ip 1.2.3.4\nsentinel announce-port 26381/g" sentinel.conf

}

start_redis(){
	cd $SHELL_FOLDER
	docker-compose up -d
}

stop_redis
init_dir
init_conf
start_redis