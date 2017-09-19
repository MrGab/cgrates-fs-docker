#!/bin/bash

echo "Setting mysql credentials if not set..."
sed -i "s/cgr-db-name/$MYSQL_DATABASE/g" /etc/cgrates/cgrates.json
sed -i "s/cgr-db-user/$MYSQL_USER/g" /etc/cgrates/cgrates.json
sed -i "s/cgr-db-password/$MYSQL_PASSWORD/g" /etc/cgrates/cgrates.json

echo “Waiting redis-cgr to be started on port 6379...”
while ! nc -z redis-cgr 6379; do  
 sleep 1
done
echo "cgrates container detected Redis is running"

echo “Waiting mysql-cgr to be started on port 3306...”
while ! nc -z mysql-cgr 3306; do  
 sleep 1
done
echo "cgrates container detected MySQL is running"

echo “Waiting freeswitch-cgr to be started on port 8021...”
while ! nc -z freeswitch-cgr 8021; do
 sleep 1
done
echo "cgrates container detected FreeSWITCH is running"

echo "Starting cgr-engine..."
cgr-engine
