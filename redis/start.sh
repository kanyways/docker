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
	mkdir -p ./redis/nodes-6382/{conf,data}
	mkdir -p ./redis/nodes-6383/{conf,data}
	mkdir -p ./redis/nodes-6384/{conf,data}
}

init_conf(){
	cd $SHELL_FOLDER
	cp redis.conf ./redis/nodes-6379/conf/
	cd $SHELL_FOLDER/redis/nodes-6379/conf/
	sudo sed  -i "s/bind 127.0.0.1/# bind 127.0.0.1/g" redis.conf
	sudo sed  -i "s/appendonly no/appendonly yes/g" redis.conf
	# sudo sed  -i "s/daemonize no/daemonize yes/g" redis.conf
	sudo sed  -i "s/protected-mode yes/protected-mode no/g" redis.conf
	sudo sed  -i "s/# cluster-enabled yes/# cluster-enabled yes\ncluster-enabled yes/g" redis.conf
	sudo sed  -i "s/# cluster-config-file nodes-6379.conf/# cluster-config-file nodes-6379.conf\ncluster-config-file nodes-6379.conf/g" redis.conf
	sudo sed  -i "s/# cluster-node-timeout 15000/# cluster-node-timeout 15000\ncluster-node-timeout 5000/g" redis.conf
	sudo sed  -i "s/# # bind 127.0.0.1 ::1/# bind 127.0.0.1 ::1/g" redis.conf
	sudo sed  -i "s/logfile \"\"/logfile \"redis.log\"/g" redis.conf
	sudo sed  -i "s/notify-keyspace-events \"\"/notify-keyspace-events Ex/g" redis.conf
	sudo sed  -i "s/# cluster-announce-bus-port 6380/# cluster-announce-bus-port 6380\ncluster-announce-port 6379\ncluster-announce-bus-port 16379/g" redis.conf
	sudo sed  -i "s/# requirepass foobared/# requirepass foobared\nrequirepass 12345678/g" redis.conf
	sudo sed  -i "s/# masterauth <master-password>/# masterauth <master-password>\nmasterauth 12345678/g" redis.conf

	cp $SHELL_FOLDER/redis/nodes-6379/conf/redis.conf $SHELL_FOLDER/redis/nodes-6380/conf/
	cp $SHELL_FOLDER/redis/nodes-6379/conf/redis.conf $SHELL_FOLDER/redis/nodes-6381/conf/
	cp $SHELL_FOLDER/redis/nodes-6379/conf/redis.conf $SHELL_FOLDER/redis/nodes-6382/conf/
	cp $SHELL_FOLDER/redis/nodes-6379/conf/redis.conf $SHELL_FOLDER/redis/nodes-6383/conf/
	cp $SHELL_FOLDER/redis/nodes-6379/conf/redis.conf $SHELL_FOLDER/redis/nodes-6384/conf/
}

start_redis(){
	cd $SHELL_FOLDER
	docker-compose up -d
}

create_cluster(){
	echo 开始睡眠
	sleep 10
	echo 结束睡眠
	docker exec -it redis-6379 redis-cli -a cruelm00n --cluster create 172.18.0.4:6379 172.18.0.5:6379 172.18.0.6:6379 172.18.0.7:6379 172.18.0.8:6379 172.18.0.9:6379 --cluster-replicas 1 /yes
}

stop_redis
init_dir
init_conf
start_redis
create_cluster