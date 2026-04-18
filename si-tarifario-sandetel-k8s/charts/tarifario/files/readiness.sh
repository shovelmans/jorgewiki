#!/bin/sh

MYSQL_PWD="$MYSQL_PASSWORD" mysql -u "$MYSQL_USER" -D "$MYSQL_DATABASE" -e "SHOW TABLES LIKE 'productos';" 2>/dev/null | grep -q productos