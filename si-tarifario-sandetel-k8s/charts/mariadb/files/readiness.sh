#!/bin/sh

OK="[✔]"
FAIL="[✘]"

# Check 1 - Conexión MariaDB
if ! MYSQL_PWD="$MYSQL_PASSWORD" mysqladmin -u "$MYSQL_USER" ping 2>/dev/null | grep -q "alive"; then
  echo "READINESS FAILED | Conexion MariaDB: $FAIL"
  exit 1
fi

# Check 2 - Base de datos
DB_EXISTS=$(MYSQL_PWD="$MYSQL_PASSWORD" mysql -u "$MYSQL_USER" -e "SHOW DATABASES LIKE '$MYSQL_DATABASE';" 2>/dev/null | grep -c "$MYSQL_DATABASE")
if [ "$DB_EXISTS" -eq 0 ]; then
  echo "READINESS FAILED | BD '$MYSQL_DATABASE' no existe: $FAIL"
  exit 1
fi

# Check 3 - Tabla productos
TABLE_EXISTS=$(MYSQL_PWD="$MYSQL_PASSWORD" mysql -u "$MYSQL_USER" -D "$MYSQL_DATABASE" -e "SHOW TABLES LIKE 'productos';" 2>/dev/null | grep -c "productos")
if [ "$TABLE_EXISTS" -eq 0 ]; then
  echo "READINESS FAILED | Tabla 'productos' no existe: $FAIL"
  exit 1
fi

# Check 4 - Filas
ROW_COUNT=$(MYSQL_PWD="$MYSQL_PASSWORD" mysql -u "$MYSQL_USER" -D "$MYSQL_DATABASE" -e "SELECT COUNT(*) FROM productos;" 2>/dev/null | tail -1)
if [ "$ROW_COUNT" -eq 0 ]; then
  echo "READINESS FAILED | Tabla 'productos' sin datos: $FAIL"
  exit 1
fi

echo "READINESS OK | Conexion: $OK | BD: $OK | Tabla: $OK | Filas: $OK $ROW_COUNT"
exit 0