$ kubectl apply -f bloque1/01-namespace-kafka.yaml
namespace/kafka created

$ kubectl get ns kafka
NAME    STATUS   AGE
kafka   Active   4s

helm repo add strimzi https://strimzi.io/charts/
helm repo update

helm upgrade --install strimzi strimzi/strimzi-kafka-operator \
  -n kafka \
  -f bloque1/02-strimzi-values.yaml

kubectl get pods -n kafka

kubectl apply -f bloque1/03-kafka-basico.yaml
kubectl get pods -n kafka -w


Y lo que has desplegado
kafka namespace
├── strimzi-cluster-operator
├── lab-kafka
│   ├── 2 brokers
│   ├── 1 controller
│   └── bootstrap service
└── entity operator

Siguiente paso: crear el primer topic.
kubectl apply -f bloque1/04-topic-prueba.yaml
kubectl get kafkatopic -n kafka

Perfecto. Paso validado.

Ya tienes:

el clúster Kafka levantado
el topic topic-prueba
3 particiones
factor de replicación 2


5.1 Saca la imagen exacta del broker

Ejecuta esto:

kubectl get pod lab-kafka-broker-0 -n kafka -o jsonpath='{.spec.containers[0].image}{"\n"}'
> quay.io/strimzi/kafka:0.51.0-kafka-4.2.0
Guarda ese valor porque lo vas a pegar en el fichero de abajo.

> CREAMOS POR POR SI QUEREMOS ENTRAR CON CLI
kubectl apply -f bloque1/05-kafka-cli-client.yaml
kubectl get pod kafka-cli -n kafka

> PARA ENTRAR POR GUI
kubectl apply -f bloque1/06-kafbat-configmap.yaml
kubectl get configmap kafbat-ui-config -n kafka

kubectl apply -f bloque1/07-kafbat-deployment.yaml
kubectl get pods -n kafka -l app=kafbat-ui
kubectl apply -f bloque1/08-kafbat-service.yaml
kubectl get nodes -o wide



producir mensajes y consumirlos.
kubectl exec -it -n kafka kafka-cli -- bash -lc '/opt/kafka/bin/kafka-console-producer.sh --bootstrap-server lab-kafka-kafka-bootstrap:9092 --topic topic-prueba'
kubectl exec -it -n kafka kafka-cli -- bash -lc '/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server lab-kafka-kafka-bootstrap:9092 --topic topic-prueba --from-beginning'



