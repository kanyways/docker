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
	read -p "请输入Redis密码：" PASSWORD
	read -p "请输入本地对外Ip：" REMOTEADDRESS

	cd $SHELL_FOLDER
	cp redis.conf ./redis/nodes-6379/conf/
	cd $SHELL_FOLDER/redis/nodes-6379/conf/

	sudo sed  -i "s/bind 127.0.0.1/# bind 127.0.0.1/g" redis.conf
	sudo sed  -i "s/appendonly no/appendonly yes/g" redis.conf
	# sudo sed  -i "s/daemonize no/daemonize yes/g" redis.conf
	sudo sed  -i "s/protected-mode yes/protected-mode no/g" redis.conf
	sudo sed  -i "s/# cluster-enabled yes/# cluster-enabled yes\ncluster-enabled yes/g" redis.conf
	sudo sed  -i "s/# cluster-node-timeout 15000/# cluster-node-timeout 15000\ncluster-node-timeout 5000/g" redis.conf
	sudo sed  -i "s/# # bind 127.0.0.1 ::1/# bind 127.0.0.1 ::1/g" redis.conf
	sudo sed  -i "s/logfile \"\"/logfile \"redis.log\"/g" redis.conf
	sudo sed  -i "s/notify-keyspace-events \"\"/notify-keyspace-events Ex/g" redis.conf
	#sudo sed  -i "s/# cluster-announce-bus-port 6380/# cluster-announce-bus-port 6380\ncluster-announce-port 6379\ncluster-announce-bus-port 16379/g" redis.conf
	sudo sed  -i "s/# requirepass foobared/# requirepass foobared\nrequirepass $PASSWORD/g" redis.conf
	sudo sed  -i "s/# masterauth <master-password>/# masterauth <master-password>\nmasterauth $PASSWORD/g" redis.conf

	cp $SHELL_FOLDER/redis/nodes-6379/conf/redis.conf $SHELL_FOLDER/redis/nodes-6380/conf/
	cp $SHELL_FOLDER/redis/nodes-6379/conf/redis.conf $SHELL_FOLDER/redis/nodes-6381/conf/
	cp $SHELL_FOLDER/redis/nodes-6379/conf/redis.conf $SHELL_FOLDER/redis/nodes-6382/conf/
	cp $SHELL_FOLDER/redis/nodes-6379/conf/redis.conf $SHELL_FOLDER/redis/nodes-6383/conf/
	cp $SHELL_FOLDER/redis/nodes-6379/conf/redis.conf $SHELL_FOLDER/redis/nodes-6384/conf/

	# 配置Redis端口
	
	sed -i '/# If port 0 is specified Redis will not listen on a TCP socket\./{:a;n;s/port 6379/# port 6379\nport 6379/g;/# TCP listen() backlog\./!ba}' $SHELL_FOLDER/redis/nodes-6379/conf/redis.conf
	sed -i '/# If port 0 is specified Redis will not listen on a TCP socket\./{:a;n;s/port 6379/# port 6379\nport 6380/g;/# TCP listen() backlog\./!ba}' $SHELL_FOLDER/redis/nodes-6380/conf/redis.conf
	sed -i '/# If port 0 is specified Redis will not listen on a TCP socket\./{:a;n;s/port 6379/# port 6379\nport 6381/g;/# TCP listen() backlog\./!ba}' $SHELL_FOLDER/redis/nodes-6381/conf/redis.conf
	sed -i '/# If port 0 is specified Redis will not listen on a TCP socket\./{:a;n;s/port 6379/# port 6379\nport 6382/g;/# TCP listen() backlog\./!ba}' $SHELL_FOLDER/redis/nodes-6382/conf/redis.conf
	sed -i '/# If port 0 is specified Redis will not listen on a TCP socket\./{:a;n;s/port 6379/# port 6379\nport 6383/g;/# TCP listen() backlog\./!ba}' $SHELL_FOLDER/redis/nodes-6383/conf/redis.conf
	sed -i '/# If port 0 is specified Redis will not listen on a TCP socket\./{:a;n;s/port 6379/# port 6379\nport 6384/g;/# TCP listen() backlog\./!ba}' $SHELL_FOLDER/redis/nodes-6384/conf/redis.conf

	# 配置Cluster的节点文件
	
	sudo sed  -i "s/# cluster-config-file nodes-6379.conf/# cluster-config-file nodes-6379.conf\ncluster-config-file nodes-6379.conf/g" $SHELL_FOLDER/redis/nodes-6379/conf/redis.conf
	sudo sed  -i "s/# cluster-config-file nodes-6379.conf/# cluster-config-file nodes-6379.conf\ncluster-config-file nodes-6380.conf/g" $SHELL_FOLDER/redis/nodes-6380/conf/redis.conf
	sudo sed  -i "s/# cluster-config-file nodes-6379.conf/# cluster-config-file nodes-6379.conf\ncluster-config-file nodes-6381.conf/g" $SHELL_FOLDER/redis/nodes-6381/conf/redis.conf
	sudo sed  -i "s/# cluster-config-file nodes-6379.conf/# cluster-config-file nodes-6379.conf\ncluster-config-file nodes-6382.conf/g" $SHELL_FOLDER/redis/nodes-6382/conf/redis.conf
	sudo sed  -i "s/# cluster-config-file nodes-6379.conf/# cluster-config-file nodes-6379.conf\ncluster-config-file nodes-6383.conf/g" $SHELL_FOLDER/redis/nodes-6383/conf/redis.conf
	sudo sed  -i "s/# cluster-config-file nodes-6379.conf/# cluster-config-file nodes-6379.conf\ncluster-config-file nodes-6384.conf/g" $SHELL_FOLDER/redis/nodes-6384/conf/redis.conf


	# 配置Cluster的对外IP
	
	sudo sed  -i "s/# cluster-announce-bus-port 6380/# cluster-announce-bus-port 6380\ncluster-announce-ip $REMOTEADDRESS\ncluster-announce-port 6379\ncluster-announce-bus-port 16379/g" $SHELL_FOLDER/redis/nodes-6379/conf/redis.conf
	sudo sed  -i "s/# cluster-announce-bus-port 6380/# cluster-announce-bus-port 6380\ncluster-announce-ip $REMOTEADDRESS\ncluster-announce-port 6380\ncluster-announce-bus-port 16380/g" $SHELL_FOLDER/redis/nodes-6380/conf/redis.conf
	sudo sed  -i "s/# cluster-announce-bus-port 6380/# cluster-announce-bus-port 6380\ncluster-announce-ip $REMOTEADDRESS\ncluster-announce-port 6381\ncluster-announce-bus-port 16381/g" $SHELL_FOLDER/redis/nodes-6381/conf/redis.conf
	sudo sed  -i "s/# cluster-announce-bus-port 6380/# cluster-announce-bus-port 6380\ncluster-announce-ip $REMOTEADDRESS\ncluster-announce-port 6382\ncluster-announce-bus-port 16382/g" $SHELL_FOLDER/redis/nodes-6382/conf/redis.conf
	sudo sed  -i "s/# cluster-announce-bus-port 6380/# cluster-announce-bus-port 6380\ncluster-announce-ip $REMOTEADDRESS\ncluster-announce-port 6383\ncluster-announce-bus-port 16383/g" $SHELL_FOLDER/redis/nodes-6383/conf/redis.conf
	sudo sed  -i "s/# cluster-announce-bus-port 6380/# cluster-announce-bus-port 6380\ncluster-announce-ip $REMOTEADDRESS\ncluster-announce-port 6384\ncluster-announce-bus-port 16384/g" $SHELL_FOLDER/redis/nodes-6384/conf/redis.conf
}

start_redis(){
	cd $SHELL_FOLDER
	docker-compose up -d
}

create_cluster(){
	echo 开始睡眠
	sleep 2
	echo 结束睡眠
	docker exec -it redis-6379 redis-cli -a $PASSWORD --cluster create $REMOTEADDRESS:6379 $REMOTEADDRESS:6380 $REMOTEADDRESS:6381 $REMOTEADDRESS:6382 $REMOTEADDRESS:6383 $REMOTEADDRESS:6384 --cluster-replicas 1
}

stop_redis
init_dir
init_conf
start_redis
create_cluster