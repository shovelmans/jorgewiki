#!/bin/sh

echo "[READINESS] Iniciando comprobación - $(date)"

echo "[READINESS] Comprobando conexión a MariaDB..."
if ! MYSQL_PWD="$MYSQL_PASSWORD" mysqladmin -u "$MYSQL_USER" ping 2>/dev/null | grep -q "alive"; then
  echo "[READINESS] FALLO - MariaDB no responde al ping"
  exit 1
fi
echo "[READINESS] OK - MariaDB responde"

echo "[READINESS] Comprobando base de datos '$MYSQL_DATABASE'..."
DB_EXISTS=$(MYSQL_PWD="$MYSQL_PASSWORD" mysql -u "$MYSQL_USER" -e "SHOW DATABASES LIKE '$MYSQL_DATABASE';" 2>/dev/null | grep -c "$MYSQL_DATABASE")
if [ "$DB_EXISTS" -eq 0 ]; then
  echo "[READINESS] FALLO - Base de datos '$MYSQL_DATABASE' no existe"
  exit 1
fi
echo "[READINESS] OK - Base de datos '$MYSQL_DATABASE' existe"

echo "[READINESS] Comprobando tabla 'productos'..."
TABLE_EXISTS=$(MYSQL_PWD="$MYSQL_PASSWORD" mysql -u "$MYSQL_USER" -D "$MYSQL_DATABASE" -e "SHOW TABLES LIKE 'productos';" 2>/dev/null | grep -c "productos")
if [ "$TABLE_EXISTS" -eq 0 ]; then
  echo "[READINESS] FALLO - Tabla 'productos' no existe"
  exit 1
fi
echo "[READINESS] OK - Tabla 'productos' existe"

echo "[READINESS] Comprobando datos en 'productos'..."
ROW_COUNT=$(MYSQL_PWD="$MYSQL_PASSWORD" mysql -u "$MYSQL_USER" -D "$MYSQL_DATABASE" -e "SELECT COUNT(*) FROM productos;" 2>/dev/null | tail -1)
echo "[READINESS] OK - Tabla 'productos' tiene $ROW_COUNT filas"

echo "[READINESS] Todas las comprobaciones superadas - MariaDB LISTA"
exit 0