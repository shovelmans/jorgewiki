# Kubernetes RBAC Lab -- Multi-User Setup

## 🎯 Objetivo

Configurar tres identidades en un cluster Kubernetes:

-   👑 **admin** (cluster-admin)
-   👨‍💻 **developer** (acceso limitado a project-dev)
-   👀 **auditor** (solo lectura global)

Y poder cambiar entre usuarios usando:

``` bash
kubectl config use-context <usuario>
```

------------------------------------------------------------------------

# 🧪 Paso 1 -- Crear namespaces

``` bash
kubectl create namespace project-dev
kubectl create namespace project-prod
```

------------------------------------------------------------------------

# 🧪 Paso 2 -- Crear ServiceAccounts

``` bash
kubectl create serviceaccount developer -n project-dev
kubectl create serviceaccount auditor -n project-dev
```

------------------------------------------------------------------------

# 🧪 Paso 3 -- Crear Role para developer (namespace project-dev)

``` bash
kubectl create role developer-role   --namespace=project-dev   --verb=get,list,watch,create,update,patch,delete   --resource=pods,deployments
```

------------------------------------------------------------------------

# 🧪 Paso 4 -- Crear RoleBinding

``` bash
kubectl create rolebinding developer-binding   --namespace=project-dev   --role=developer-role   --serviceaccount=project-dev:developer
```

Verificar:

``` bash
kubectl get role -n project-dev
kubectl get rolebinding -n project-dev
```

------------------------------------------------------------------------

# 🧪 Paso 5 -- Generar token developer

``` bash
kubectl create token developer -n project-dev
```

Copiar el token.

------------------------------------------------------------------------

# 🧪 Paso 6 -- Crear usuario developer en kubeconfig

``` bash
kubectl config set-credentials developer --token=TU_TOKEN_AQUI
```

Obtener nombre del cluster:

``` bash
kubectl config get-clusters
```

Crear contexto:

``` bash
kubectl config set-context developer   --cluster=NOMBRE_CLUSTER   --user=developer   --namespace=project-dev
```

------------------------------------------------------------------------

# 🧪 Paso 7 -- Probar developer

``` bash
kubectl config use-context developer
kubectl get pods
kubectl run nginx --image=nginx
kubectl get ns   # Debe fallar
```

------------------------------------------------------------------------

# 🧪 Paso 8 -- Volver a admin

``` bash
kubectl config use-context do-fra1-k8s-1-34-1-do-3-fra1-1771665243120
```

------------------------------------------------------------------------

# 🧪 Paso 9 -- Crear permisos auditor (ClusterRole view)

``` bash
kubectl create clusterrolebinding auditor-binding   --clusterrole=view   --serviceaccount=project-dev:auditor
```

------------------------------------------------------------------------

# 🧪 Paso 10 -- Generar token auditor

``` bash
kubectl create token auditor -n project-dev
```

------------------------------------------------------------------------

# 🧪 Paso 11 -- Crear usuario auditor

``` bash
kubectl config set-credentials auditor --token=TOKEN_AUDITOR
```

Crear contexto:

``` bash
kubectl config set-context auditor   --cluster=NOMBRE_CLUSTER   --user=auditor
```

------------------------------------------------------------------------

# 🧪 Paso 12 -- Probar auditor

``` bash
kubectl config use-context auditor
kubectl get ns              # Debe funcionar
kubectl run test --image=nginx -n project-dev   # Debe fallar
```

------------------------------------------------------------------------

# 🔐 Resumen de usuarios

  -------------------------------------------------------------------------------------------------------------
  Usuario     Tipo de          Cómo cambiar  Role               Ámbito         Puede hacer        No puede
              identidad                                                                           hacer
  ----------- ---------------- ------------- ------------------ -------------- ------------------ -------------
  admin       Token            use-context   cluster-admin      Cluster        Todo               Nada
              DigitalOcean     do-fra1...                       completo                          

  developer   ServiceAccount   use-context   Role               project-dev    CRUD               Ver otros
                               developer     (developer-role)                  pods/deployments   namespaces,
                                                                                                  modificar
                                                                                                  RBAC

  auditor     ServiceAccount   use-context   ClusterRole (view) Cluster-wide   get/list/watch     Crear o
                               auditor                          lectura                           borrar
                                                                                                  recursos
  -------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------

# 🧠 Conceptos clave

-   Role → Namespace scope\
-   ClusterRole → Cluster scope\
-   RoleBinding → Vincula Role en namespace\
-   ClusterRoleBinding → Vincula ClusterRole globalmente\
-   Autenticación ≠ Autorización

------------------------------------------------------------------------

Fin del laboratorio.
