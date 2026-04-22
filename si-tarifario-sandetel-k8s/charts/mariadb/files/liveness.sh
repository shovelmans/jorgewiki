#!/bin/sh

OK="[✔]"
FAIL="[✘]"
MAX_THREADS=10

# Check 1 - MariaDB responde
if ! MYSQL_PWD="$MYSQL_PASSWORD" mysqladmin -u "$MYSQL_USER" ping 2>/dev/null | grep -q "alive"; then
  echo "LIVENESS FAILED | MariaDB no responde: $FAIL"
  exit 1
fi

# Check 2 - Threads running
THREADS=$(MYSQL_PWD="$MYSQL_PASSWORD" mysql -u "$MYSQL_USER" -e "SHOW STATUS LIKE 'Threads_running';" 2>/dev/null | tail -1 | awk '{print $2}')

if [ -z "$THREADS" ]; then
  echo "LIVENESS FAILED | No se pudo obtener Threads_running: $FAIL"
  exit 1
fi

if [ "$THREADS" -gt "$MAX_THREADS" ]; then
  echo "LIVENESS FAILED | Sobrecarga: ${THREADS} threads activos > ${MAX_THREADS}: $FAIL"
  exit 1
fi

echo "LIVENESS OK | Threads_running: ${THREADS}/${MAX_THREADS}: $OK"
exit 0