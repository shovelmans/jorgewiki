> PASO 1: DESPLEGAR ARGOCD
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
kubectl create namespace argocd
helm install argocd argo/argo-cd --namespace argocd --create-namespace --set server.service.type=NodePort
kubectl get svc -n argocd
kubectl get nodes -o wide
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

> PASO 2: DESPLEGAR GRAFANA OPERADOR
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install grafana-operator grafana/grafana-operator --namespace monitoring --create-namespace
kubectl get crd | grep grafana
| CRD                                                     | Kind que puedes crear            |
| ------------------------------------------------------- | -------------------------------- |
| grafanas.grafana.integreatly.org                        | `Grafana`                        |
| grafanadashboards.grafana.integreatly.org               | `GrafanaDashboard`               |
| grafanadatasources.grafana.integreatly.org              | `GrafanaDataSource`              |
| grafanafolders.grafana.integreatly.org                  | `GrafanaFolder`                  |
| grafanaalertrulegroups.grafana.integreatly.org          | `GrafanaAlertRuleGroup`          |
| grafanacontactpoints.grafana.integreatly.org            | `GrafanaContactPoint`            |
| grafananotificationpolicies.grafana.integreatly.org     | `GrafanaNotificationPolicy`      |
| grafananotificationpolicyroutes.grafana.integreatly.org | `GrafanaNotificationPolicyRoute` |
| grafananotificationtemplates.grafana.integreatly.org    | `GrafanaNotificationTemplate`    |
| grafanamutetimings.grafana.integreatly.org              | `GrafanaMuteTiming`              |
| grafanalibrarypanels.grafana.integreatly.org            | `GrafanaLibraryPanel`            |
| grafanaserviceaccounts.grafana.integreatly.org          | `GrafanaServiceAccount`          |

> PASO 3: PREPARAMOS GITHUB
Github entro con vjorgem95@gmail.com -> https://github.com/shovelmans/monitoring
Desde aqui se inicializa: /c/Users/vicentemjext/OneDrive - FUJITSU/fujitsu/personal/jorgewiki
git init
git remote add origin https://github.com/shovelmans/monitoring.git
git remote -v
git add .
git commit -m "Initial commit - Grafana operator lab"
git branch -M main
git push -u origin main

> PASO 4: CREAR APLICACION ARGOCD
kubectl apply -f monitorizacion/grafana/grafana-operador/grafana-app.yaml
kubectl get svc -n monitoring
kubectl get nodes -o wide
Usuario: admin
Contraseña: kubectl get secret instancia-grafana-admin-credentials -n monitoring -o jsonpath="{.data.GF_SECURITY_ADMIN_PASSWORD}" | base64 -d && echo

> PASO 5: CREAMOS NUESTRO DATASOURCE PROMETHEUS
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus --namespace monitoring --set server.service.type=NodePort
kubectl get svc -n monitoring
El svc que usara grafana -> prometheus-server: http://prometheus-server.monitoring.svc.cluster.local

> Si modificamos por la GUI un dashboard y queremos recrearlo solo tendremos que borrar el recurso y argocd lo desplegara de nuevo: kubectl delete grafanadashboard monitoring-dashboard -n monitoring