#!/bin/sh

OK="[✔]"
FAIL="[✘]"

RESULT=""
STATUS=0

# Check 1 - Conexión MariaDB
if ! MYSQL_PWD="$MYSQL_PASSWORD" mysqladmin -u "$MYSQL_USER" ping 2>/dev/null | grep -q "alive"; then
  RESULT="Conexion: $FAIL FALLO"
  echo "READINESS FAILED | $RESULT"
  exit 1
fi
RESULT="Conexion: $OK"

# Check 2 - Base de datos
DB_EXISTS=$(MYSQL_PWD="$MYSQL_PASSWORD" mysql -u "$MYSQL_USER" -e "SHOW DATABASES LIKE '$MYSQL_DATABASE';" 2>/dev/null | grep -c "$MYSQL_DATABASE")
if [ "$DB_EXISTS" -eq 0 ]; then
  RESULT="$RESULT | BD '$MYSQL_DATABASE': $FAIL FALLO"
  echo "READINESS FAILED | $RESULT"
  exit 1
fi
RESULT="$RESULT | BD '$MYSQL_DATABASE': $OK"

# Check 3 - Tabla productos
TABLE_EXISTS=$(MYSQL_PWD="$MYSQL_PASSWORD" mysql -u "$MYSQL_USER" -D "$MYSQL_DATABASE" -e "SHOW TABLES LIKE 'productos';" 2>/dev/null | grep -c "productos")
if [ "$TABLE_EXISTS" -eq 0 ]; then
  RESULT="$RESULT | Tabla 'productos': $FAIL FALLO"
  echo "READINESS FAILED | $RESULT"
  exit 1
fi
RESULT="$RESULT | Tabla 'productos': $OK"

# Check 4 - Filas
ROW_COUNT=$(MYSQL_PWD="$MYSQL_PASSWORD" mysql -u "$MYSQL_USER" -D "$MYSQL_DATABASE" -e "SELECT COUNT(*) FROM productos;" 2>/dev/null | tail -1)
RESULT="$RESULT | Filas: $OK $ROW_COUNT"

echo "READINESS OK | $RESULT"
exit 0