#!/bin/bash

# Install Docker-Compose
docker ps | grep -v data | awk '{print $1}' | grep -v CONTAINER | xargs docker stop
docker ps -a | grep -v data | awk '{print $1}' | grep -v CONTAINER | xargs docker rm

docker run -d --name data -v /opt/data:/data -v /opt/data/log:/data/log busybox echo "data-container"
docker run -d --name data-mysql -v /var/lib/mysql/ daocloud.io/koolay/mysql:latest echo "data-mysql-container"

docker run --name mysql \
           --restart=always \
           --volumes-from data-mysql \
           -p 3306:3306 \
           -e MYSQL_ROOT_PASSWORD=dev \
           -e MYSQL_DATABASE=sentry \
           -d daocloud.io/koolay/mysql:latest

docker run --name memcached \
           --restart=always \
           -p 11211:11211 \
           -d daocloud.io/koolay/memcached:latest

docker run --name redis \
           --restart=always \
           -p 6379:6379\
           -d daocloud.io/koolay/alpine-redis:latest


docker run --name fpm \
           --restart=always \
           --volumes-from data \
           --link mysql \
           --link memcached \
           --link redis \
           --add-host wx-dev.myysq.com.cn:`/sbin/ip route|awk '/default/ { print  $3}'` \
           --add-host passport-dev.myysq.com.cn:`/sbin/ip route|awk '/default/ { print  $3}'` \
           --add-host mem-dev.myysq.com.cn:`/sbin/ip route|awk '/default/ { print  $3}'` \
           --add-host msg-dev.myysq.com.cn:`/sbin/ip route|awk '/default/ { print  $3}'` \
           --add-host yf-dev.myysq.com.cn:`/sbin/ip route|awk '/default/ { print  $3}'` \
           --add-host kefu-dev.myysq.com.cn:`/sbin/ip route|awk '/default/ { print  $3}'` \
           -v /opt/etc/php/fpm/php-fpm.conf:/etc/php5/fpm/php-fpm.conf \
           -v /opt/etc/php/fpm/pool.d/www.conf:/etc/php5/fpm/pool.d/www.conf \
           -v /opt/app:/app \
           --expose 9000 \
           -e MYSQL_ROOT_PASSWORD=dev \
           -e MYSQL_DATABASE=sentry \
           -d daocloud.io/koolay/php-fpm:latest


docker run --name sentry \
           --restart=always \
           --volumes-from data \
           --link mysql \
           --link redis \
           --expose 9876 \
           -e C_FORCE_ROOT=true \
           -e SENTRY_DOCKER_DO_DB_CHECK=yes \
           -e SENTRY_URL_PREFIX=http://dev.myapp.com:8686 \
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
           --restart=always \
           --volumes-from data \
           --link fpm \
           --link sentry \
           -v /opt/etc/nginx:/etc/nginx \
           -v /opt/app:/app \
           -p 80:80 \
           -p 8080:8080 \
           -p 8686:8686 \
           -p 9876:9876 \
           -p 10083:10083 \
           -p 10099:10099 \
           -p 10085:10085 \
           -p 10086:10086 \
           -e MYSQL_ROOT_PASSWORD=dev \
           -e MYSQL_DATABASE=sentry \
           -d daocloud.io/koolay/alpine-nginx:latest
