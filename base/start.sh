#!/bin/bash
SHELL_FOLDER=$(cd $(dirname $0);pwd)


clean_logs(){
	cd ${SHELL_FOLDER}/
	echo 删除日志信息
	sudo find ${SHELL_FOLDER}/nginx -name "*.log" | xargs rm -rf '*'
	sudo find ${SHELL_FOLDER}/rmqs/logs -name "*.log" | xargs rm -rf '*'
	sudo find ${SHELL_FOLDER}/rmq/logs -name "*.log" | xargs rm -rf '*'
	sudo find ${SHELL_FOLDER}/elasticsearch -name "*.log*" | xargs rm -rf '*'
	echo 设定权限
	sudo chown -R $USER:$GROUPS ${SHELL_FOLDER}/
}

start_docker(){
	cd ${SHELL_FOLDER}/
	docker-compose up -d
}

start_redis_cluster(){
	sleep 2
	docker exec -it redis-6379 redis-cli -a cruelm00n --cluster create 172.18.0.4:6379 172.18.0.5:6379 172.18.0.6:6379 172.18.0.7:6379 172.18.0.8:6379 172.18.0.9:6379 --cluster-replicas 1
}

clean_logs
start_docker
start_redis_cluster