# 🖥️ Tarifario Informático - App Kubernetes

Aplicación full stack sencilla para consultar un tarifario de productos informáticos.

Incluye:

- 🐍 Backend en Flask
- 🗄️ Base de datos MariaDB
- 🌐 Frontend estático (HTML + CSS + JS)
- ☸️ Despliegue en Kubernetes con Helm
- 🐳 Imágenes Docker en Docker Hub

---

## 📐 Arquitectura

Browser → NodePort → Frontend (Nginx)
                ↓
            Backend (Flask API)
                ↓
            MariaDB

---

## 🚀 Funcionalidades

- Listado de productos con JOINs (endpoint `/productos`)
- Consulta dinámica de tablas:
  - categorias
  - marcas
  - productos
  - historico_precios
- Renderizado automático de tablas en frontend
- UI dinámica sin frameworks (JS puro)

---

## 🔌 Endpoints Backend

### Healthcheck
GET /health

### Listar tablas disponibles
GET /tablas

### Consultar tabla completa
GET /tabla/<nombre_tabla>

### Listado enriquecido de productos
GET /productos

---

## 🐳 Docker

### Backend
docker build -t shovelman/backend:latest .
docker push shovelman/backend:latest

### Frontend
docker build -t shovelman/frontend:latest .
docker push shovelman/frontend:latest

---

## ☸️ Kubernetes

Namespace:
tarifario

### Componentes desplegados

- Deployment + Service → mariadb
- Deployment + Service → tarifario-backend
- Deployment + Service → tarifario-frontend (NodePort)

### Acceso frontend

http://<NODE-IP>:30081

---

## ⚙️ Configuración (Helm values.yaml)

### MariaDB
mariadb:
  name: mariadb
  image: mariadb:10.3
  port: 3306

  database:
    name: tarifario
    user: tarifario
    password: password

### Backend
backend:
  name: tarifario-backend
  replicas: 1

  image:
    repository: shovelman/backend
    tag: latest

  database:
    host: mariadb
    port: 3306
    name: tarifario
    user: tarifario
    password: password

### Frontend
frontend:
  name: tarifario-frontend

  image:
    repository: shovelman/frontend
    tag: latest

  service:
    type: NodePort
    nodePort: 30081

---

## 🌐 Frontend

Frontend estático servido con Nginx:

- index.html
- style.css
- script.js

---

## 🔁 Flujo completo

1. Usuario accede al frontend
2. JS llama a /api/tablas
3. Backend devuelve tablas permitidas
4. Usuario selecciona tabla
5. Frontend llama a /api/tabla/<tabla>
6. Backend consulta MariaDB
7. Se renderiza la tabla en el navegador

---

## 🧠 Buenas prácticas aplicadas

- Separación frontend/backend
- Uso de Services para comunicación interna
- Variables de entorno para configuración
- Backend genérico controlado
- Despliegue reproducible con Helm
- Imágenes en Docker Hub

---

## 🔮 Mejoras futuras

- Ingress
- Configuración por entorno
- Autenticación
- Paginación
- CI/CD con ArgoCD
