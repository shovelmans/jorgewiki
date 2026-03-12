🧪 Laboratorio Kubernetes – PostgreSQL Dump & Restore entre namespaces

Arquitectura del laboratorio:

Entorno	Namespace	Uso
Producción	produccion	Base original
Desarrollo	desarrollo	Base restaurada desde dump


1️⃣ Crear los namespaces
Paso	Comando	Qué ocurre
Crear namespace prod	kubectl create ns produccion	Namespace de producción
Crear namespace dev	kubectl create ns desarrollo	Namespace de desarrollo
Verificar	kubectl get ns	Confirmar creación

2️⃣ Desplegar PostgreSQL en producción

Ejemplo simple con Deployment + PVC.

Paso	Acción	Detalle
Crear PVC	almacenamiento persistente	guarda datos
Crear Deployment	contenedor postgres	base funcionando
Crear Service	acceso interno	puerto 5432

kubectl apply -f postgres.yaml


3️⃣ Conectarte a PostgreSQL
kubectl exec -it -n produccion deploy/postgres -- psql -U postgres

Paso 4 — Crear estructura de base de datos

Dentro de psql ejecuta estos comandos.

1️⃣ Crear base de datos
CREATE DATABASE empresa;

Conectarte a ella:

\c empresa
2️⃣ Crear usuarios
CREATE USER appuser WITH PASSWORD 'app123';
CREATE USER reportuser WITH PASSWORD 'report123';
3️⃣ Crear esquemas
CREATE SCHEMA ventas;
CREATE SCHEMA rrhh;
4️⃣ Crear tablas
CREATE TABLE ventas.clientes (
 id SERIAL PRIMARY KEY,
 nombre TEXT,
 ciudad TEXT
);

CREATE TABLE rrhh.empleados (
 id SERIAL PRIMARY KEY,
 nombre TEXT,
 puesto TEXT
);
5️⃣ Insertar datos
INSERT INTO ventas.clientes(nombre, ciudad) VALUES
('Jorge','Madrid'),
('Ana','Sevilla'),
('Luis','Valencia');

INSERT INTO rrhh.empleados(nombre, puesto) VALUES
('Carlos','DevOps'),
('Lucia','DBA');
6️⃣ Dar permisos
GRANT USAGE ON SCHEMA ventas TO appuser;
GRANT SELECT ON ALL TABLES IN SCHEMA ventas TO appuser;

GRANT USAGE ON SCHEMA rrhh TO reportuser;
GRANT SELECT ON ALL TABLES IN SCHEMA rrhh TO reportuser;
7️⃣ Verificar
\dn
\dt ventas.*
\dt rrhh.*

SELECT * FROM ventas.clientes;
SELECT * FROM rrhh.empleados;







> CREAR DUMP
NS ORIGEN
kubectl exec -n produccion postgres-588c978d85-rghqc -- bash -c "pg_dumpall -U postgres --roles-only > /tmp/roles.sql"
kubectl exec -n produccion postgres-588c978d85-rghqc -- bash -c "pg_dump -U postgres empresa > /tmp/empresa.sql"
kubectl exec -n produccion postgres-588c978d85-rghqc -- bash -c "ls -lh /tmp"
kubectl exec -n produccion postgres-588c978d85-rghqc -- head /tmp/empresa.sql


kubectl exec -n produccion postgres-588c978d85-rghqc -- sh -c "cat /tmp/roles.sql" > roles.sql
kubectl exec -n produccion postgres-588c978d85-rghqc -- sh -c "cat /tmp/empresa.sql" > empresa.sql



CREAR POSTGRES EN DESARROLLO
kubectl apply -f postgres-des.yaml
kubectl get pods -n desarrollo

Copiar dumps al pod de desarrollo
kubectl exec -i -n desarrollo postgres-588c978d85-r9cxt -- sh -c "cat > /tmp/roles.sql" < roles.sql
kubectl exec -i -n desarrollo postgres-588c978d85-r9cxt -- sh -c "cat > /tmp/empresa.sql" < empresa.sql
kubectl exec -n desarrollo postgres-588c978d85-r9cxt -- sh -c 'ls -lh /tmp'


Paso 1 — Crear roles y usuarios
kubectl exec -it -n desarrollo postgres-588c978d85-r9cxt -- sh -c "psql -U postgres -f /tmp/roles.sql"
kubectl exec -it -n desarrollo postgres-588c978d85-r9cxt -- sh -c "createdb -U postgres empresa"
kubectl exec -it -n desarrollo postgres-588c978d85-r9cxt -- sh -c "psql -U postgres -d empresa -f /tmp/empresa.sql"

kubectl exec -it -n desarrollo postgres-588c978d85-r9cxt -- psql -U postgres
\l \c empresa \dt ventas.* \dt rrhh.* \echo '--- DATOS ---' \; SELECT * FROM ventas.clientes; SELECT * FROM rrhh.empleados;