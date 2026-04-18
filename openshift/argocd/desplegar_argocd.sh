#!/usr/bin/env bash
set -euo pipefail

### ===== CONFIGURACION =====
NAMESPACE="argocd"
RELEASE="argocd"
HELM_REPO_NAME="argo"
HELM_REPO_URL="https://argoproj.github.io/argo-helm"
CHART_NAME="argo/argo-cd"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALUES_FILE="${SCRIPT_DIR}/argocd-values.yaml"

### ===== FUNCIONES =====
check_commands() {
  for cmd in kubectl helm base64; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo "ERROR: no existe el comando '$cmd' en el sistema."
      exit 1
    fi
  done
}

create_values_file() {
  echo "==> Generando values en: $VALUES_FILE"
  cat > "$VALUES_FILE" <<'EOF'
server:
  service:
    type: NodePort

configs:
  params:
    server.insecure: true
EOF
}

create_argocd() {
  check_commands

  echo "==> Creando namespace si no existe..."
  kubectl get ns "$NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$NAMESPACE"

  echo "==> Añadiendo repo Helm de Argo..."
  helm repo add "$HELM_REPO_NAME" "$HELM_REPO_URL" >/dev/null 2>&1 || true
  helm repo update >/dev/null

  create_values_file

  echo "==> Desplegando Argo CD con Helm..."
  helm upgrade --install "$RELEASE" "$CHART_NAME" \
    -n "$NAMESPACE" \
    -f "$VALUES_FILE"

  echo "==> Localizando deployment del server..."
  SERVER_DEPLOYMENT=""
  for i in {1..30}; do
    SERVER_DEPLOYMENT=$(kubectl get deploy -n "$NAMESPACE" \
      -l app.kubernetes.io/name=argocd-server \
      -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)

    if [ -n "${SERVER_DEPLOYMENT:-}" ]; then
      break
    fi
    sleep 5
  done

  if [ -z "${SERVER_DEPLOYMENT:-}" ]; then
    echo "ERROR: no se encontró el deployment de argocd-server."
    echo "Deployments encontrados en $NAMESPACE:"
    kubectl get deploy -n "$NAMESPACE"
    exit 1
  fi

  echo "==> Esperando despliegue del server: $SERVER_DEPLOYMENT"
  kubectl rollout status deployment/"$SERVER_DEPLOYMENT" -n "$NAMESPACE" --timeout=300s

  echo "==> Esperando secret de password inicial..."
  for i in {1..60}; do
    if kubectl get secret argocd-initial-admin-secret -n "$NAMESPACE" >/dev/null 2>&1; then
      break
    fi
    sleep 5
  done

  if ! kubectl get secret argocd-initial-admin-secret -n "$NAMESPACE" >/dev/null 2>&1; then
    echo "ERROR: no se encontró el secret inicial de Argo CD."
    exit 1
  fi

  echo "==> Localizando service del server..."
  SERVER_SERVICE=""
  for i in {1..30}; do
    SERVER_SERVICE=$(kubectl get svc -n "$NAMESPACE" \
      -l app.kubernetes.io/name=argocd-server \
      -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)

    if [ -n "${SERVER_SERVICE:-}" ]; then
      break
    fi
    sleep 5
  done

  if [ -z "${SERVER_SERVICE:-}" ]; then
    echo "ERROR: no se encontró el service de argocd-server."
    echo "Services encontrados en $NAMESPACE:"
    kubectl get svc -n "$NAMESPACE"
    exit 1
  fi

  echo "==> Obteniendo NodePort..."
  NODE_PORT=$(kubectl get svc "$SERVER_SERVICE" -n "$NAMESPACE" -o jsonpath='{.spec.ports[0].nodePort}')

  if [ -z "${NODE_PORT:-}" ]; then
    echo "ERROR: no se pudo obtener el NodePort del servicio $SERVER_SERVICE."
    exit 1
  fi

  echo "==> Obteniendo IP del nodo..."
  NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}')

  if [ -z "${NODE_IP:-}" ]; then
    NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
  fi

  if [ -z "${NODE_IP:-}" ]; then
    echo "ERROR: no se pudo obtener IP del nodo."
    exit 1
  fi

  echo "==> Obteniendo password inicial..."
  ADMIN_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n "$NAMESPACE" -o jsonpath='{.data.password}' | base64 -d)

  echo
  echo "=========================================="
  echo "ARGO CD DESPLEGADO CORRECTAMENTE"
  echo "URL:      http://${NODE_IP}:${NODE_PORT}"
  echo "USUARIO:  admin"
  echo "PASSWORD: ${ADMIN_PASSWORD}"
  echo "NAMESPACE:${NAMESPACE}"
  echo "SERVICE:  ${SERVER_SERVICE}"
  echo "DEPLOY:   ${SERVER_DEPLOYMENT}"
  echo "VALUES:   ${VALUES_FILE}"
  echo "=========================================="
}

destroy_argocd() {
  check_commands

  echo "==> Eliminando release Helm si existe..."
  if helm status "$RELEASE" -n "$NAMESPACE" >/dev/null 2>&1; then
    helm uninstall "$RELEASE" -n "$NAMESPACE"
  else
    echo "Release $RELEASE no existe en $NAMESPACE"
  fi

  echo "==> Eliminando namespace si existe..."
  if kubectl get ns "$NAMESPACE" >/dev/null 2>&1; then
    kubectl delete ns "$NAMESPACE"
  else
    echo "Namespace $NAMESPACE no existe"
  fi

  echo "==> Eliminando CRDs de Argo CD si existen..."
  kubectl delete crd applications.argoproj.io applicationsets.argoproj.io appprojects.argoproj.io --ignore-not-found=true

  echo "==> Eliminando fichero values si existe..."
  if [ -f "$VALUES_FILE" ]; then
    rm -f "$VALUES_FILE"
    echo "Borrado: $VALUES_FILE"
  else
    echo "No existe: $VALUES_FILE"
  fi

  echo
  echo "=========================================="
  echo "ARGO CD ELIMINADO"
  echo "NAMESPACE:${NAMESPACE}"
  echo "RELEASE:  ${RELEASE}"
  echo "=========================================="
}

### ===== MENU =====
echo "Selecciona una opcion:"
echo "1) Crear Argo CD"
echo "2) Destruir Argo CD"
read -rp "Opcion [1-2]: " OPTION

case "$OPTION" in
  1)
    create_argocd
    ;;
  2)
    destroy_argocd
    ;;
  *)
    echo "Opcion no valida. Debe ser 1 o 2."
    exit 1
    ;;
esac