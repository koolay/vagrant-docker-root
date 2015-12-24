#!/bin/bash

# Install Docker-Compose
#docker ps | awk '{print $1}' | xargs docker stop
#docker ps -a | awk '{print $1}' | xargs docker rm

docker run -d --name data -v /opt/data:/data -v /opt/data/log:/data/log busybox echo "data-container"
docker run -d --name data-mysql -v /var/lib/mysql/ daocloud.io/koolay/mysql:latest echo "data-mysql-container"

docker run --name mysql \
           --volumes-from data-mysql \
           -p 3306:3306 \
           -e MYSQL_ROOT_PASSWORD=dev \
           -e MYSQL_DATABASE=sentry \
           -d daocloud.io/koolay/mysql:latest

docker run --name memcached \
           -p 11211:11211 \
           -d daocloud.io/koolay/memcached:latest

docker run --name redis \
           -p 6379:6379\
           -d daocloud.io/koolay/alpine-redis:latest


docker run --name fpm \
           --volumes-from data \
           --link mysql \
           --link redis \
           -v /opt/etc/php:/etc/php5 \
           -v /opt/app:/app \
           -p 9000:9000 \
           -e MYSQL_ROOT_PASSWORD=dev \
           -e MYSQL_DATABASE=sentry \
           -d daocloud.io/koolay/php-fpm:latest


docker run --name sentry \
           --volumes-from data \
           --link mysql \
           --link redis \
           -p 9898:9898 \
           -e C_FORCE_ROOT=true \
           -e SENTRY_DOCKER_DO_DB_CHECK=yes \
           -e SENTRY_URL_PREFIX=http://dev.myapp.com:9876 \
           -e SENTRY_ADMIN_USERNAME=admin \
           -e SENTRY_ADMIN_PASSWORD=dev \
           -e SENTRY_ADMIN_EMAIL=dev@foo.com \
           -e DB_HOST=mysql \
           -e DB_USERNAME=root \
           -e DB_PASSWORD=dev \
           -e DB_NAME=sentry \
           -e DB_PORT=3306 \
           -e REDIS_HOST=redis \
           -e REDIS_PORT=6379 \
           -d daocloud.io/koolay/sentry:latest


docker run --name nginx \
           --volumes-from data \
           --link fpm \
           --link sentry \
           -v /opt/etc/nginx:/etc/nginx \
           -v /opt/app:/app \
           -p 8080:8080 \
           -p 9876:9876 \
           -e MYSQL_ROOT_PASSWORD=dev \
           -e MYSQL_DATABASE=sentry \
           -d daocloud.io/koolay/alpine-nginx:latest
