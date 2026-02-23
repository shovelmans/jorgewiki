🎯 Objetivo del laboratorio

Vas a montar en tu Kubernetes de DigitalOcean un cluster Kafka con 2 brokers (modo KRaft, sin ZooKeeper) en el namespace herramientas-horizontales, cada broker con su propio PVC. Luego crearás dos aplicaciones en namespaces distintos (app1 y app2) que actuarán ambas como producer y consumer, enviándose mensajes entre sí a través de topics. El objetivo es entender realmente cómo funciona Kafka: brokers, topics, replicación, comunicación entre namespaces y alta disponibilidad.

🔵 PASO 1 — Crear namespace de Kafka
kubectl create namespace herramientas-horizontales
kubectl get ns | grep herramientas-horizontales

🔵 PASO 2 — Añadir el repositorio de Helm (Bitnami)
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm repo list

🔵 PASO 3 — Instalar Kafka (2 brokers, KRaft, sin ZooKeeper)
helm install kafka bitnami/kafka \
  --namespace herramientas-horizontales \
  --set kraft.enabled=true \
  --set zookeeper.enabled=false \
  --set replicaCount=2 \
  --set controller.replicaCount=2 \
  --set persistence.size=1Gi
kubectl get pods -n herramientas-horizontales
