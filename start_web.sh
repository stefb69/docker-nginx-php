#!/bin/bash

reset=$1
type=$2

sed -i -e "s###" 
ln -s /docker-nginx-php/build/conf/$type.conf /docker-nginx-php/build/conf/web.conf
mkdir -p /var/www/web 

if [ $reset == "true" ];then
  docker-compose stop
  docker-compose rm -f
fi 

docker-compose build
docker-compose up -d

