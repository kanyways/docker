#!/bin/bash
SHELL_FOLDER=$(cd $(dirname $0);pwd)

cd ${SHELL_FOLDER}/

echo 停止服务
docker-compose down

echo 设定权限
sudo chown -R $USER:$GROUPS ${SHELL_FOLDER}/

echo 删除日志信息
sudo find ${SHELL_FOLDER}/nginx -name "*.log" | xargs rm -rf '*'
sudo find ${SHELL_FOLDER}/rmqs/logs -name "*.log" | xargs rm -rf '*'
sudo find ${SHELL_FOLDER}/rmq/logs -name "*.log" | xargs rm -rf '*'
sudo find ${SHELL_FOLDER}/elasticsearch -name "*.log*" | xargs rm -rf '*'



