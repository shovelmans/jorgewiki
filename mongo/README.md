# MongoDB ReplicaSet + Mongo Express en Kubernetes

**Documento de Deployment Profesional**  
**Fecha**: 2026-06-08  
**Autor**: DevOps Engineering  
**Stack**: Kubernetes (3+ nodos) + Bitnami MongoDB + Mongo Express

---

## 📋 Tabla de Contenidos

1. [Requisitos Previos](#requisitos-previos)
2. [Arquitectura](#arquitectura)
3. [Instalación Paso a Paso](#instalación-paso-a-paso)
4. [Verificación](#verificación)
5. [Acceso a la GUI](#acceso-a-la-gui)
6. [Comandos Útiles](#comandos-útiles)
7. [Troubleshooting](#troubleshooting)
8. [Limpieza Completa](#limpieza-completa)

---

## 🎯 Requisitos Previos

### Infraestructura
- **Kubernetes**: 1.21+ (probado en v1.35.5)
- **Nodos**: Mínimo 3 nodos (recomendado para ReplicaSet)
- **Memoria**: 4GB mínimo disponible (2GB para MongoDB + 512MB buffer)
- **Storage**: StorageClass disponible (ej: `do-block-storage`, `standard`, `fast-ssd`)

### Herramientas Instaladas
```bash
kubectl version --client
helm version
```

### Helm Repositories
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

---

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────┐
│         Kubernetes Cluster (3 nodos)                │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────────────────────────────────────────┐   │
│  │        MongoDB ReplicaSet                    │   │
│  ├──────────────────────────────────────────────┤   │
│  │ ┌──────────┐  ┌──────────┐  ┌──────────┐   │   │
│  │ │mongodb-0 │  │mongodb-1 │  │ arbiter  │   │   │
│  │ │  (DATA)  │  │  (DATA)  │  │(VOTING)  │   │   │
│  │ └──────────┘  └──────────┘  └──────────┘   │   │
│  └──────────────────────────────────────────────┘   │
│                        ↓                            │
│  ┌──────────────────────────────────────────────┐   │
│  │    Mongo Express (GUI) - NodePort 30081      │   │
│  └──────────────────────────────────────────────┘   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Componentes:**
- **MongoDB ReplicaSet**: 3 miembros (2 data + 1 arbiter)
- **Almacenamiento**: Persistent Volumes (20Gi por pod)
- **Autenticación**: SCRAM habilitada
- **Interfaz**: Mongo Express en NodePort 30081

---

## 🚀 Instalación Paso a Paso

### PASO 1: Crear Namespace y Secrets

```bash
# Crear namespace dedicado para MongoDB
kubectl create namespace mongodb

# Crear secret con la contraseña root
kubectl create secret generic mongodb-root-password \
  --from-literal=password='MongoDBRootPass123!' \
  -n mongodb
```

**Explicación:**
- El namespace aísla MongoDB del resto de aplicaciones
- El secret almacena la contraseña de forma segura (encoded en base64)

---

### PASO 2: Instalar MongoDB con Helm (Bitnami)

```bash
helm install mongodb bitnami/mongodb \
  --namespace mongodb \
  --set auth.enabled=true \
  --set auth.rootPassword='MongoDBRootPass123!' \
  --set auth.username=appuser \
  --set auth.password='AppUserPass123!' \
  --set auth.database=myapp \
  --set architecture=replicaset \
  --set replicaSet.enabled=true \
  --set replicas=3 \
  --set persistence.enabled=true \
  --set persistence.storageClass=do-block-storage \
  --set persistence.size=20Gi \
  --set resources.requests.memory=512Mi \
  --set resources.requests.cpu=250m \
  --set resources.limits.memory=1Gi \
  --set resources.limits.cpu=500m \
  --set podAntiAffinity=hard \
  --set metrics.enabled=false \
  --wait
```

**Parámetros Explicados:**

| Parámetro | Valor | Explicación |
|-----------|-------|-------------|
| `architecture` | `replicaset` | Despliega 3 pods en ReplicaSet |
| `replicas` | `3` | 2 data nodes + 1 arbiter |
| `persistence.size` | `20Gi` | Almacenamiento por pod |
| `storageClass` | `do-block-storage` | **CAMBIAR SEGÚN TU INFRAESTRUCTURA** |
| `resources.requests.memory` | `512Mi` | Mínimo garantizado |
| `resources.limits.memory` | `1Gi` | Máximo permitido |
| `podAntiAffinity` | `hard` | Obliga pods en nodos diferentes |
| `--wait` | - | Espera a que esté listo |

**⚠️ IMPORTANTE**: Cambiar `storageClass` según tu entorno:
- **DigitalOcean**: `do-block-storage`
- **AWS**: `gp2` o `io1`
- **GCP**: `standard-rwo` o `premium-rwo`
- **Local**: `standard` (default)

---

### PASO 3: Verificar Instalación de MongoDB

```bash
# Ver estado de los pods
kubectl get pods -n mongodb -w

# Esperar hasta ver 3 pods en Running:
# mongodb-0           1/1     Running
# mongodb-1           1/1     Running
# mongodb-arbiter-0   1/1     Running

# Presionar Ctrl+C para salir del watch
```

**Salida esperada:**
```
NAME                READY   STATUS    RESTARTS   AGE
mongodb-0           1/1     Running   0          2m40s
mongodb-1           1/1     Running   0          93s
mongodb-arbiter-0   1/1     Running   0          2m40s
```

---

### PASO 4: Crear ConfigMap para Mongo Express

```bash
# Crear ConfigMap con credenciales de conexión a MongoDB
kubectl create configmap mongo-express-config \
  --from-literal=ME_CONFIG_MONGODB_URL='mongodb://root:MongoDBRootPass123!@mongodb-0.mongodb-headless.mongodb.svc.cluster.local:27017/?authSource=admin' \
  --from-literal=ME_CONFIG_MONGODB_ADMINUSERNAME='root' \
  --from-literal=ME_CONFIG_MONGODB_ADMINPASSWORD='MongoDBRootPass123!' \
  -n mongodb
```

---

### PASO 5: Desplegar Mongo Express

```bash
# Crear el manifest de Mongo Express
cat > /tmp/mongo-express.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongo-express
  namespace: mongodb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mongo-express
  template:
    metadata:
      labels:
        app: mongo-express
    spec:
      containers:
      - name: mongo-express
        image: mongo-express:latest
        ports:
        - containerPort: 8081
        env:
        - name: ME_CONFIG_MONGODB_URL
          valueFrom:
            configMapKeyRef:
              name: mongo-express-config
              key: ME_CONFIG_MONGODB_URL
        - name: ME_CONFIG_MONGODB_ADMINUSERNAME
          valueFrom:
            configMapKeyRef:
              name: mongo-express-config
              key: ME_CONFIG_MONGODB_ADMINUSERNAME
        - name: ME_CONFIG_MONGODB_ADMINPASSWORD
          valueFrom:
            configMapKeyRef:
              name: mongo-express-config
              key: ME_CONFIG_MONGODB_ADMINPASSWORD
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"

---
apiVersion: v1
kind: Service
metadata:
  name: mongo-express
  namespace: mongodb
spec:
  selector:
    app: mongo-express
  ports:
  - protocol: TCP
    port: 8081
    targetPort: 8081
    nodePort: 30081
  type: NodePort
EOF

# Aplicar el manifest
kubectl apply -f /tmp/mongo-express.yaml

# Verificar que esté Running
kubectl get pods -n mongodb mongo-express -w
```

**Esperado:**
```
NAME                             READY   STATUS    RESTARTS   AGE
mongo-express-78d568bdb9-5hnfg   1/1     Running   0          22s
```

---

## ✅ Verificación

### Verificar MongoDB ReplicaSet

```bash
# Ver status del ReplicaSet
kubectl exec -it mongodb-0 -n mongodb -- mongosh \
  --host localhost:27017 \
  --username root \
  --password 'MongoDBRootPass123!' \
  --authenticationDatabase admin \
  --eval "rs.status()"
```

**Salida esperada**: `"myState": 1` (PRIMARY), `"ok": 1`

### Verificar Services

```bash
# Ver todos los services en el namespace
kubectl get svc -n mongodb

# Salida esperada:
# NAME                       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)
# mongodb-headless           ClusterIP   None         <none>        27017/TCP
# mongodb-arbiter-headless   ClusterIP   None         <none>        27017/TCP
# mongo-express              NodePort    10.114...    <none>        8081:30081/TCP
```

### Verificar PersistentVolumes

```bash
# Ver que se crearon los PVCs
kubectl get pvc -n mongodb

# Salida esperada:
# NAME                    STATUS   VOLUME                  CAPACITY   ACCESS MODES   STORAGECLASS
# datadir-mongodb-0       Bound    pvc-xxxx...             20Gi       RWO            do-block-storage
# datadir-mongodb-1       Bound    pvc-xxxx...             20Gi       RWO            do-block-storage
```

---

## 🌐 Acceso a la GUI

### Obtener IPs de los Nodos

```bash
kubectl get nodes -o wide
```

**Salida esperada:**
```
NAME                  STATUS   ROLES   INTERNAL-IP   EXTERNAL-IP      
pool-default-3utcmc   Ready    <none>  10.114.0.2    164.92.137.3     
pool-default-3utmep   Ready    <none>  10.114.0.5    167.71.51.225    
pool-default-3utmes   Ready    <none>  10.114.0.4    138.68.93.36     
```

### Acceder a Mongo Express

Abre en tu navegador cualquiera de estas URLs:

- `http://164.92.137.3:30081`
- `http://167.71.51.225:30081`
- `http://138.68.93.36:30081`

**Credenciales por defecto:**
```
Usuario: admin
Contraseña: pass
```

### Interfaz

Una vez dentro, verás:
- **Databases**: `admin`, `config`, `local`
- **Server Status**: Información del cluster
- **Crear Bases de Datos**: Botón "+ Create Database"
- **Gestionar Colecciones**: Ver/editar documentos JSON

---

## 🛠️ Comandos Útiles

### Conectar desde CLI (mongosh)

```bash
# Dentro del cluster
kubectl exec -it mongodb-0 -n mongodb -- mongosh \
  --host localhost:27017 \
  --username root \
  --password 'MongoDBRootPass123!' \
  --authenticationDatabase admin

# Desde tu máquina local (con port-forward)
kubectl port-forward -n mongodb mongodb-0 27017:27017 &
mongosh "mongodb://root:MongoDBRootPass123!@localhost:27017/?authSource=admin"
```

### Ver Logs

```bash
# Logs de MongoDB
kubectl logs -f mongodb-0 -n mongodb

# Logs de Mongo Express
kubectl logs -f -l app=mongo-express -n mongodb

# Logs del último contenedor crasheado
kubectl logs --previous mongodb-0 -n mongodb
```

### Ver Recursos

```bash
# CPU y Memoria en uso
kubectl top pods -n mongodb

# Información detallada de un pod
kubectl describe pod mongodb-0 -n mongodb

# Eventos del namespace
kubectl get events -n mongodb --sort-by='.lastTimestamp'
```

### Ejecutar Comandos en MongoDB

```bash
# Crear una base de datos y colección
kubectl exec -it mongodb-0 -n mongodb -- mongosh \
  --host localhost:27017 \
  --username root \
  --password 'MongoDBRootPass123!' \
  --authenticationDatabase admin \
  --eval "db.getSiblingDB('testdb').testcol.insertOne({name: 'Jorge', age: 22})"

# Ver todas las bases de datos
kubectl exec -it mongodb-0 -n mongodb -- mongosh \
  --host localhost:27017 \
  --username root \
  --password 'MongoDBRootPass123!' \
  --authenticationDatabase admin \
  --eval "show databases"
```

### Escalabilidad

```bash
# Aumentar replicas de Mongo Express (si necesitas HA)
kubectl scale deployment mongo-express --replicas=2 -n mongodb

# Ver estado del scaling
kubectl rollout status deployment/mongo-express -n mongodb
```

---

## 🐛 Troubleshooting

### MongoDB no inicia

**Problema**: Los pods quedan en `Pending` o `CrashLoopBackOff`

**Solución**:
```bash
# Ver eventos
kubectl describe pod mongodb-0 -n mongodb

# Ver logs
kubectl logs mongodb-0 -n mongodb

# Verificar StorageClass disponible
kubectl get storageclass

# Si falta storage, cambiar en el helm install:
# --set persistence.storageClass=standard
```

### Mongo Express no conecta a MongoDB

**Problema**: Página en blanco o "Cannot connect"

**Solución**:
```bash
# Verificar que el ConfigMap está bien
kubectl get configmap mongo-express-config -n mongodb -o yaml

# Verificar DNS desde el pod
kubectl exec -it mongo-express-xxx -n mongodb -- nslookup mongodb-0.mongodb-headless.mongodb.svc.cluster.local

# Verificar conectividad
kubectl exec -it mongo-express-xxx -n mongodb -- nc -zv mongodb-0.mongodb-headless.mongodb.svc.cluster.local 27017
```

### ReplicaSet no se inicializa

**Problema**: `rs.status()` devuelve error o `myState: -1`

**Solución**:
```bash
# Reiniciar el ReplicaSet
kubectl exec -it mongodb-0 -n mongodb -- mongosh \
  --host localhost:27017 \
  --username root \
  --password 'MongoDBRootPass123!' \
  --authenticationDatabase admin \
  --eval "rs.initiate()"
```

### Memoria insuficiente

**Problema**: Pods quedan en `Pending` con mensaje "Insufficient memory"

**Solución**:
```bash
# Reducir requests en el helm install:
--set resources.requests.memory=256Mi
--set resources.limits.memory=512Mi

# O agregar más nodos al cluster
```

---

## 🗑️ Limpieza Completa

### Eliminar todo sin dejar rastro

```bash
# 1. Desinstalar Mongo Express
kubectl delete deployment mongo-express -n mongodb
kubectl delete svc mongo-express -n mongodb
kubectl delete configmap mongo-express-config -n mongodb

# 2. Desinstalar MongoDB (Helm)
helm uninstall mongodb -n mongodb

# 3. Eliminar namespace completo
# ADVERTENCIA: Esto borra TODO en el namespace, incluyendo PVCs
kubectl delete namespace mongodb

# 4. Verificar que no queda nada
kubectl get namespace | grep mongodb
kubectl get pvc --all-namespaces | grep mongodb
```

### Eliminar solo MongoDB pero mantener Mongo Express

```bash
helm uninstall mongodb -n mongodb
# Los datos persistirán en los PVCs
```

### Backup antes de eliminar

```bash
# Exportar todas las bases de datos
kubectl exec -it mongodb-0 -n mongodb -- mongodump \
  --username=root \
  --password='MongoDBRootPass123!' \
  --authenticationDatabase=admin \
  --out=/dump

# Copiar el dump a tu máquina
kubectl cp mongodb/mongodb-0:/dump ./mongodb-backup
```

---

## 📊 Resumen de Credenciales

```
========== MONGODB ==========
Root User:        root
Root Password:    MongoDBRootPass123!
App User:         appuser
App Password:     AppUserPass123!
App Database:     myapp
Auth Database:    admin

Connection String (dentro del cluster):
mongodb://root:MongoDBRootPass123!@mongodb-0.mongodb-headless.mongodb.svc.cluster.local:27017/?authSource=admin

========== MONGO EXPRESS ==========
Usuario:          admin
Contraseña:       pass
Puerto:           30081 (NodePort)
```

---

## 📚 Referencias

- **Bitnami MongoDB Helm Chart**: https://github.com/bitnami/charts/tree/main/bitnami/mongodb
- **MongoDB Official Docs**: https://docs.mongodb.com/
- **Kubernetes Persistence**: https://kubernetes.io/docs/concepts/storage/persistent-volumes/
- **Mongo Express**: https://github.com/mongo-express/mongo-express

---

## 🎓 Notas Profesionales

### Para Producción

1. **Aumentar ReplicaSet a 5+ miembros** (2 data, 2 data, 1 arbiter)
2. **Habilitar TLS/SSL** en MongoDB
3. **Configurar autenticación LDAP/SADC**
4. **Implementar backups automatizados** (Velero, Percona)
5. **Monitorar con Prometheus + Grafana**
6. **Usar Ingress en lugar de NodePort**
7. **Configurar NetworkPolicies**

### Escalabilidad

- **Vertical**: Aumentar recursos por pod
- **Horizontal**: Escalar a más shards o réplicas
- **Storage**: Usar SSD para mejor performance

### Seguridad

- ✅ Cambiar credenciales default
- ✅ No exponer MongoDB sin autenticación
- ✅ Usar secrets de Kubernetes en lugar de variables
- ✅ Implementar RBAC
- ✅ Cifrar datos en tránsito (TLS)

---

**Documento versión 1.0 - Junio 2026**