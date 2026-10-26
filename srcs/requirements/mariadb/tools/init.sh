#!/bin/bash
set -e

DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_PASSWORD=$(cat /run/secrets/db_password)

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld /var/lib/mysql

if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo ">>> Initialisation de la base MariaDB..."

    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    mariadbd --user=mysql --datadir=/var/lib/mysql --skip-networking &
    pid=$!

    for i in $(seq 1 30); do
        if mysqladmin ping > /dev/null 2>&1; then
            break
        fi
        sleep 1
    done

    mysql -u root <<EOF
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown
    wait $pid 2>/dev/null || true
    echo ">>> Base initialisée."
fi

exec mariadbd --user=mysql --datadir=/var/lib/mysql
