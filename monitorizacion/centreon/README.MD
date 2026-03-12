Despliegue de Centreon en Kubernetes (Lab)
1. Crear namespace
kubectl create namespace centreon
2. Desplegar Centreon

Aplicar el deployment:

kubectl apply -f centreon-deployment.yaml

Comprobar que el pod está levantado:

kubectl get pods -n centreon
3. Acceder al contenedor

Entrar al pod:

kubectl exec -it -n centreon centreon-bd7786c97-xltnb -- sh
4. Verificar componentes instalados

Comprobar que Centreon existe:

ls /usr/share/centreon

Verificar binarios principales:

ls /usr/sbin/mysqld
ls /usr/sbin/httpd

Verificar base de datos inicializada:

ls /var/lib/mysql
5. Arrancar MariaDB

Comprobar si está ejecutándose:

ps aux | grep mysqld

Si no está corriendo:

mysqld_safe &

Verificar:

ps aux | grep maria
6. Arrancar Apache
httpd -DFOREGROUND &

Verificar:

ps aux | grep httpd
7. Arrancar PHP-FPM

Comprobar si PHP está activo:

ps aux | grep php

Si no está corriendo:

php-fpm &

Si aparece error de socket:

mkdir -p /run/php-fpm
php-fpm &

Verificar:

ps aux | grep php
8. Exponer Centreon

Crear el service:

kubectl apply -f centreon-service.yaml

Verificar:

kubectl get svc -n centreon

Ejemplo:

centreon   NodePort   10.x.x.x   80:30080/TCP
9. Obtener IP del nodo
kubectl get nodes -o wide

Ejemplo:

EXTERNAL-IP
168.144.33.245
10. Acceder a Centreon

Abrir en navegador:

http://IP_DEL_NODO:30080/centreon/login

Ejemplo:

http://168.144.33.245:30080/centreon/login
11. Resetear contraseña admin (si falla login)

Entrar al contenedor:

kubectl exec -it -n centreon centreon-bd7786c97-xltnb -- sh

Entrar a MariaDB:

mysql -u root

Seleccionar base de datos:

use centreon;

Ver usuarios:

SELECT contact_id, contact_alias FROM contact;

Ver tabla de passwords:

SHOW TABLES LIKE '%password%';
SELECT * FROM contact_password;

Eliminar passwords anteriores del admin:

DELETE FROM contact_password
WHERE contact_id = 1;

Crear nuevo password:

INSERT INTO contact_password (password, contact_id, creation_date)
VALUES (MD5('admin'), 1, UNIX_TIMESTAMP());

Verificar:

SELECT * FROM contact_password;
12. Credenciales finales
URL
http://168.144.33.245:30080/centreon/login
usuario: admin
password: admin