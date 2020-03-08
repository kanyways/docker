#!/bin/bash

SHELL_FOLDER=$(cd $(dirname $0);pwd)

# 编译elasticsearch的镜像，添加ik分词器
buid_elasticsearch() {
    cd ${SHELL_FOLDER}/build/elasticsearch
    docker build --no-cache -t kanyme/elasticsearch:7.6.0 .
}

# 删除tag为<none>的镜像文件
clean_all_none(){
    docker rmi `docker images | grep  "<none>" | awk '{print $3}'`
}

# 初始化文件夹
init_dir_data(){
  cd ${SHELL_FOLDER}
  # 创建 elasticsearch 需要使用到的文件夹
  sudo mkdir -p ./elasticsearch/data/master/{data,logs}
  sudo mkdir -p ./elasticsearch/data/node0/{data,logs}
  sudo mkdir -p ./elasticsearch/data/node1/{data,logs}
  sudo mkdir -p ./elasticsearch/data/tribe/{data,logs}
  # 配置 elasticsearch 需要使用到的文件夹权限
  sudo chmod 777 ./elasticsearch/data/master/{data,logs}
  sudo chmod 777 ./elasticsearch/data/node0/{data,logs}
  sudo chmod 777 ./elasticsearch/data/node1/{data,logs}
  sudo chmod 777 ./elasticsearch/data/tribe/{data,logs}
  # 配置宿主机的vm.max_map_count的值，否则会报错
  sysctl -w vm.max_map_count=262144

  echo mongodb
  sudo mkdir -p ./mongodb/{data,logs}

  echo mysql
  sudo mkdir -p ./mysql/{conf,data,logs}
  sudo cp my.cnf ./mysql/conf/

  echo nginx
  sudo mkdir -p ./nginx/{conf,html,logs,sites,ssl}
  sudo cp nginx.conf ./nginx/conf/


  # 配置rocketmq的文件夹
  sudo mkdir -p ./rmqs/{logs,store}
  sudo mkdir -p ./rmq/{logs,store,brokerconf}
  sudo cp broker.conf ./rmq/brokerconf/

  # 配置rocketmq目录权限
  sudo chmod -R 777 ./rmqs/{logs,store}
  sudo chmod -R 777 ./rmq/{logs,store}

  # 创建redis目录
  cd $SHELL_FOLDER;
  sudo rm -rf ./redis/
  # 创建文件夹
  sudo mkdir -p ./redis/nodes-6379/{conf,data}
  sudo mkdir -p ./redis/nodes-6380/{conf,data}
  sudo mkdir -p ./redis/nodes-6381/{conf,data}
  sudo mkdir -p ./redis/nodes-6382/{conf,data}
  sudo mkdir -p ./redis/nodes-6383/{conf,data}
  sudo mkdir -p ./redis/nodes-6384/{conf,data}

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
  sudo sed  -i "s/# requirepass foobared/# requirepass foobared\nrequirepass 密码/g" redis.conf
  sudo sed  -i "s/# masterauth <master-password>/# masterauth <master-password>\nmasterauth 密码/g" redis.conf

  cp $SHELL_FOLDER/redis/nodes-6379/conf/redis.conf $SHELL_FOLDER/redis/nodes-6380/conf/
  cp $SHELL_FOLDER/redis/nodes-6379/conf/redis.conf $SHELL_FOLDER/redis/nodes-6381/conf/
  cp $SHELL_FOLDER/redis/nodes-6379/conf/redis.conf $SHELL_FOLDER/redis/nodes-6382/conf/
  cp $SHELL_FOLDER/redis/nodes-6379/conf/redis.conf $SHELL_FOLDER/redis/nodes-6383/conf/
  cp $SHELL_FOLDER/redis/nodes-6379/conf/redis.conf $SHELL_FOLDER/redis/nodes-6384/conf/

  docker pull docker.elastic.co/kibana/kibana:7.6.0
}

# 清理日志信息
clean_logs(){
  cd ${SHELL_FOLDER}
  sudo find ${SHELL_FOLDER}/nginx -name "*.log" | xargs rm -rf '*'
  sudo find ${SHELL_FOLDER}/rmqs/logs -name "*.log" | xargs rm -rf '*'
  sudo find ${SHELL_FOLDER}/rmq/logs -name "*.log" | xargs rm -rf '*'
  sudo find ${SHELL_FOLDER}/elasticsearch -name "*.log" | xargs rm -rf '*'
}

buid_elasticsearch
clean_all_none
init_dir_data
clean_logs