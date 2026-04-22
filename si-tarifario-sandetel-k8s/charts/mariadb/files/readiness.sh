#!/bin/sh

OK="[✔]"
FAIL="[✘]"
INFO="[•]"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " READINESS CHECK - $(date)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check 1 - Conexión MariaDB
printf " %-35s" "Conexion MariaDB..."
if ! MYSQL_PWD="$MYSQL_PASSWORD" mysqladmin -u "$MYSQL_USER" ping 2>/dev/null | grep -q "alive"; then
  echo "$FAIL FALLO"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 1
fi
echo "$OK OK"

# Check 2 - Base de datos
printf " %-35s" "Base de datos '$MYSQL_DATABASE'..."
DB_EXISTS=$(MYSQL_PWD="$MYSQL_PASSWORD" mysql -u "$MYSQL_USER" -e "SHOW DATABASES LIKE '$MYSQL_DATABASE';" 2>/dev/null | grep -c "$MYSQL_DATABASE")
if [ "$DB_EXISTS" -eq 0 ]; then
  echo "$FAIL FALLO"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 1
fi
echo "$OK OK"

# Check 3 - Tabla productos
printf " %-35s" "Tabla 'productos'..."
TABLE_EXISTS=$(MYSQL_PWD="$MYSQL_PASSWORD" mysql -u "$MYSQL_USER" -D "$MYSQL_DATABASE" -e "SHOW TABLES LIKE 'productos';" 2>/dev/null | grep -c "productos")
if [ "$TABLE_EXISTS" -eq 0 ]; then
  echo "$FAIL FALLO"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 1
fi
echo "$OK OK"

# Check 4 - Datos
printf " %-35s" "Filas en 'productos'..."
ROW_COUNT=$(MYSQL_PWD="$MYSQL_PASSWORD" mysql -u "$MYSQL_USER" -D "$MYSQL_DATABASE" -e "SELECT COUNT(*) FROM productos;" 2>/dev/null | tail -1)
echo "$OK $ROW_COUNT filas"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " $OK MariaDB LISTA"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
exit 0