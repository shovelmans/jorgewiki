#!/bin/sh

OK="[✔]"
FAIL="[✘]"
MAX_SECONDS=2

# Check 1 - MariaDB responde
if ! MYSQL_PWD="$MYSQL_PASSWORD" mysqladmin -u "$MYSQL_USER" ping 2>/dev/null | grep -q "alive"; then
  echo "LIVENESS FAILED | MariaDB no responde: $FAIL"
  exit 1
fi

# Check 2 - Tiempo de respuesta
START=$(date +%s)
MYSQL_PWD="$MYSQL_PASSWORD" mysql -u "$MYSQL_USER" -D "$MYSQL_DATABASE" -e "SELECT 1;" 2>/dev/null
END=$(date +%s)
ELAPSED=$((END - START))

if [ "$ELAPSED" -gt "$MAX_SECONDS" ]; then
  echo "LIVENESS FAILED | MariaDB sobrecargada, respuesta en ${ELAPSED}s > ${MAX_SECONDS}s: $FAIL"
  exit 1
fi

echo "LIVENESS OK | MariaDB responde en ${ELAPSED}s: $OK"
exit 0