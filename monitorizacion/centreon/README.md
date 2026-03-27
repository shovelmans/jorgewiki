# Despliegue de Centreon en Kubernetes (Lab)

## 1. Crear namespace

``` bash
kubectl create namespace centreon
```

------------------------------------------------------------------------

## 2. Desplegar Centreon

Aplicar el deployment:

``` bash
kubectl apply -f centreon-deployment.yaml
```

Comprobar que el pod está levantado:

``` bash
kubectl get pods -n centreon -w
```

------------------------------------------------------------------------

## 3. Acceder al contenedor

Entrar al pod:

``` bash
kubectl exec -it -n centreon centreon-bd7786c97-q8m7d -- sh
```

------------------------------------------------------------------------

## 4. Verificar componentes instalados

Comprobar que Centreon existe:

``` bash
ls /usr/share/centreon
```

Verificar binarios principales:

``` bash
ls /usr/sbin/mysqld
ls /usr/sbin/httpd
```

Verificar base de datos inicializada:

``` bash
ls /var/lib/mysql
```

------------------------------------------------------------------------

## 5. Arrancar MariaDB

Comprobar si está ejecutándose:

``` bash
ps aux | grep mysqld
```

Si no está corriendo:

``` bash
mysqld_safe &
```

Verificar:

``` bash
ps aux | grep maria
```

------------------------------------------------------------------------

## 6. Arrancar Apache

``` bash
httpd -DFOREGROUND &
```

Verificar:

``` bash
ps aux | grep httpd
```

------------------------------------------------------------------------

## 7. Arrancar PHP-FPM

Comprobar si PHP está activo:

``` bash
ps aux | grep php
```

Si no está corriendo:

``` bash
php-fpm &
```

Si aparece error de socket:

``` bash
mkdir -p /run/php-fpm
php-fpm &
```

Verificar:

``` bash
ps aux | grep php
```

------------------------------------------------------------------------

## 8. Exponer Centreon

Crear el service:

``` bash
kubectl apply -f centreon-service.yaml
```

Verificar:

``` bash
kubectl get svc -n centreon
```

Ejemplo:

    centreon NodePort 10.x.x.x 80:30080/TCP

------------------------------------------------------------------------

## 9. Obtener IP del nodo

``` bash
kubectl get nodes -o wide
```

Ejemplo:

    EXTERNAL-IP 168.144.33.245

------------------------------------------------------------------------

## 10. Acceder a Centreon

Abrir en navegador:

    http://IP_DEL_NODO:30080/centreon/login

Ejemplo:

    http://168.144.33.245:30080/centreon/login

------------------------------------------------------------------------

## 11. Resetear contraseña admin (si falla login)

Entrar al contenedor:

``` bash
kubectl exec -it -n centreon centreon-bd7786c97-q8m7d -- sh
```

Entrar a MariaDB:

``` bash
mysql -u root
```

Seleccionar base de datos:

``` sql
use centreon;
```

Ver usuarios:

``` sql
SELECT contact_id, contact_alias FROM contact;
```

Ver tabla de passwords:

``` sql
SHOW TABLES LIKE '%password%';
SELECT * FROM contact_password;
```

Eliminar passwords anteriores del admin:

``` sql
DELETE FROM contact_password WHERE contact_id = 1;
```

Crear nuevo password:

``` sql
INSERT INTO contact_password (password, contact_id, creation_date)
VALUES (MD5('admin'), 1, UNIX_TIMESTAMP());
```

Verificar:

``` sql
SELECT * FROM contact_password;
```

------------------------------------------------------------------------

## 12. Credenciales finales

**URL**

    http://168.144.33.245:30080/centreon/login

**Usuario**

    admin

**Password**

    admin





CREAR DEPLOYMENT
docker build -t shovelman/k8s-healthcheck:1.0 .
docker images
docker login
docker push shovelman/k8s-healthcheck:1.0
kubectl apply -f k8s-healthcheck-deployment.yaml
kubectl get pods -n centreon
kubectl apply -f k8s-healthcheck-service.yaml
kubectl get svc -n centreon
kubectl apply -f rbac-healthcheck.yaml

kubectl run testcurl -n centreon --rm -it --image=curlimages/curl -- sh
curl http://k8s-healthcheck/health
