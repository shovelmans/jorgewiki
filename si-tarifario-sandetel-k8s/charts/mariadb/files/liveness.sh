#!/bin/sh

OK="[✔]"
FAIL="[✘]"

if ! MYSQL_PWD="$MYSQL_PASSWORD" mysqladmin -u "$MYSQL_USER" ping 2>/dev/null | grep -q "alive"; then
  echo "LIVENESS FAILED | MariaDB no responde: $FAIL"
  exit 1
fi

echo "LIVENESS OK | MariaDB responde: $OK"
exit 0