# 🗄️ MariaDB — Chaos & Restore Playbook

> **Namespace:** `tarifario` | **Deployment:** `mariadb`

---

## 1. Readiness Probe

### 💥 Romper (renombrar tabla)

```bash
kubectl exec -it deployment/mariadb -n tarifario -- \
  sh -c "MYSQL_PWD=password mysql -u tarifario -D tarifario -e 'RENAME TABLE productos TO productos_bak;'"
```

### ✅ Arreglar (restaurar nombre de tabla)

```bash
kubectl exec -it deployment/mariadb -n tarifario -- \
  sh -c "MYSQL_PWD=password mysql -u tarifario -D tarifario -e 'RENAME TABLE productos_bak TO productos;'"
```

---

## 2. Liveness Probe

### 💥 Forzar fallo de liveness (shutdown de MariaDB)

```bash
kubectl exec -it deployment/mariadb -n tarifario -- \
  sh -c "mysqladmin -u root -proot_password shutdown"
```

> ⚠️ **Destructivo controlado:** MariaDB se detiene. El liveness fallará 3 veces y Kubernetes reiniciará el pod automáticamente. Los datos se conservan gracias al PVC.

### 📺 Secuencia esperada tras el fallo

```bash
kubectl get pod -l app=mariadb -n tarifario -w
```

```
NAME                       READY   STATUS      RESTARTS      AGE
mariadb-85ffdff449-q5qg8   1/1     Running     0             16s
mariadb-85ffdff449-q5qg8   0/1     Completed   0             23s
mariadb-85ffdff449-q5qg8   0/1     Running     1 (2s ago)    24s
mariadb-85ffdff449-q5qg8   1/1     Running     1 (13s ago)   35s
```

### 🔍 Verificar eventos del pod

```bash
kubectl describe pod -l app=mariadb -n tarifario | grep -A 15 "Events"
```

---

## 3. Freeze de proceso (SIGSTOP)

### 💥 Congelar el proceso principal del contenedor

```bash
kubectl exec -it deployment/mariadb -n tarifario -- \
  sh -c "kill -STOP 1"
```

> ⚠️ **Destructivo controlado:** El proceso queda suspendido. Kubernetes detectará el fallo de liveness/readiness y actuará según la política configurada.

---

## 4. Backup

### 🔎 Verificar contenido del backup

```bash
kubectl run verify-backup --rm -it --image=busybox --restart=Never \
  --overrides='{
    "spec": {
      "volumes": [{"name":"backup","persistentVolumeClaim":{"claimName":"mariadb-backup"}}],
      "containers": [{
        "name": "verify-backup",
        "image": "busybox",
        "command": ["ls","-lh","/backup"],
        "volumeMounts": [{"name":"backup","mountPath":"/backup"}]
      }]
    }
  }' -n tarifario
```

**Salida esperada:**

```
total 24K
drwx------    2 root     root       16.0K Apr 22 12:26 lost+found
-rw-r--r--    1 root     root        8.0K Apr 22 12:26 tarifario-2026-04-22.sql
pod "verify-backup" deleted
```

---

## 5. Restore

### ♻️ Restaurar backup desde PVC

```bash
kubectl run restore --rm -it --image=mariadb:10.3 --restart=Never \
  --overrides='{
    "spec": {
      "volumes": [
        {"name":"backup","persistentVolumeClaim":{"claimName":"mariadb-backup"}}
      ],
      "containers": [{
        "name": "restore",
        "image": "mariadb:10.3",
        "command": [
          "sh","-c",
          "MYSQL_PWD=password mysql -h mariadb -u tarifario tarifario < /backup/tarifario-2026-04-22.sql && echo RESTAURACION OK"
        ],
        "volumeMounts": [{"name":"backup","mountPath":"/backup"}]
      }]
    }
  }' -n tarifario
```

> ✅ Si el proceso termina correctamente, verás `RESTAURACION OK` en la salida.
