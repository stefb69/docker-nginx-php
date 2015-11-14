#!/bin/bash

reset=$1

mkdir -p /var/www/web 

if [ $reset == "true" ];then
  docker-compose stop
  docker-compose rm -f
fi 

docker-compose build
docker-compose up -d

