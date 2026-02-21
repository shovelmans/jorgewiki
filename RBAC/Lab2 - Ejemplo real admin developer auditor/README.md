# Kubernetes RBAC Lab

## Modelo Admin / Developer (namespace) / Auditor (cluster-wide)

------------------------------------------------------------------------

## 🎯 Objetivo

Implementar el siguiente modelo de permisos en Kubernetes:

  Usuario            Permisos
  ------------------ -------------------------------------
  👑 **admin**       Control total del cluster
  👨‍💻 **developer**   Solo `view` en `project-dev`
  👀 **auditor**     Solo `view` en TODOS los namespaces

------------------------------------------------------------------------

# 🧪 PASO 1 --- Limpiar RBAC anterior

Cambiar a contexto admin:

``` bash
kubectl config use-context do-fra1-k8s-1-34-1-do-3-fra1-1771665243120
```

Eliminar configuraciones previas:

``` bash
kubectl delete rolebinding developer-binding -n project-dev
kubectl delete role developer-role -n project-dev
kubectl delete clusterrolebinding auditor-binding
```

Verificar limpieza:

``` bash
kubectl get rolebinding -n project-dev
```

------------------------------------------------------------------------

# 🧪 PASO 2 --- Permisos view solo en project-dev para developer

Usamos el ClusterRole incorporado `view` y lo limitamos mediante
RoleBinding al namespace `project-dev`.

``` bash
kubectl config use-context do-fra1-k8s-1-34-1-do-3-fra1-1771665243120

kubectl create rolebinding developer-view-binding   --namespace=project-dev   --clusterrole=view   --serviceaccount=project-dev:developer

kubectl get rolebinding -n project-dev
```

------------------------------------------------------------------------

# 🧪 PASO 3 --- Validación del developer

Cambiar a developer:

``` bash
kubectl config use-context developer
kubectl config current-context
kubectl auth whoami
```

### ✅ Debe funcionar

``` bash
kubectl get pods -n project-dev
kubectl get deployments -n project-dev
```

### ❌ No debe funcionar

``` bash
kubectl run test --image=nginx -n project-dev
kubectl get pods -n project-prod
kubectl get ns
```

------------------------------------------------------------------------

# 🧪 PASO 4 --- Permisos view globales para auditor

Volver a admin:

``` bash
kubectl config use-context do-fra1-k8s-1-34-1-do-3-fra1-1771665243120
kubectl config current-context
```

Crear ClusterRoleBinding global:

``` bash
kubectl create clusterrolebinding auditor-view-binding   --clusterrole=view   --serviceaccount=project-dev:auditor

kubectl get clusterrolebinding auditor-view-binding
```

------------------------------------------------------------------------

# 🧪 PASO 5 --- Validación completa del auditor

Cambiar a auditor:

``` bash
kubectl config use-context auditor
kubectl config current-context
kubectl auth whoami
```

### ✅ Debe funcionar

``` bash
kubectl get ns
kubectl get pods -n project-dev
kubectl get pods -n project-prod
kubectl get pods -n kube-system
kubectl get deployments -A
```

### ❌ No debe funcionar

``` bash
kubectl run test-audit --image=nginx -n project-dev
kubectl delete pod nginx -n project-dev
kubectl create namespace test-audit
kubectl create role prueba --verb=get --resource=pods -n project-dev

kubectl create rolebinding intento-escalada   --clusterrole=cluster-admin   --serviceaccount=project-dev:auditor   -n project-dev
```

------------------------------------------------------------------------

# 🔐 Arquitectura RBAC Final

    Cluster
    │
    ├── admin (cluster-admin)
    │
    ├── developer
    │     └── RoleBinding (project-dev)
    │           └── ClusterRole view
    │
    └── auditor
          └── ClusterRoleBinding
                └── ClusterRole view (global)

------------------------------------------------------------------------

# 🧠 Conceptos clave

-   `Role` → namespace scope\
-   `ClusterRole` → cluster scope\
-   `RoleBinding` → limita permisos a un namespace\
-   `ClusterRoleBinding` → aplica permisos a todo el cluster\
-   El scope lo define el tipo de binding, no el Role

------------------------------------------------------------------------

Fin del laboratorio.
