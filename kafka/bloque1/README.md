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



> Producir mensajes

Productor interactivo
kubectl exec -it -n kafka kafka-cli -- bash -lc '/opt/kafka/bin/kafka-console-producer.sh --bootstrap-server lab-kafka-kafka-bootstrap:9092 --topic topic-prueba'

Enviar un mensaje directo a ventas
MSYS_NO_PATHCONV=1 kubectl exec -i -n kafka lab-kafka-broker-0 -- /opt/kafka/bin/kafka-console-producer.sh --bootstrap-server lab-kafka-kafka-bootstrap:9092 --topic ventas <<< "tipo: zapatillas; talla:37; color:azul"

Enviar otro mensaje directo a ventas
MSYS_NO_PATHCONV=1 kubectl exec -i -n kafka lab-kafka-broker-0 -- /opt/kafka/bin/kafka-console-producer.sh --bootstrap-server lab-kafka-kafka-bootstrap:9092 --topic ventas <<< "tipo: zapatillas; talla:37; color:morado"



> Consumir mensajes

Consumir ventas con grupo grupo-ventas desde el inicio
MSYS_NO_PATHCONV=1 kubectl exec -it -n kafka kafka-cli -- /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server lab-kafka-kafka-bootstrap:9092 --topic ventas --group grupo-ventas --from-beginning

Consumir ventas con grupo grupo-ventas solo desde el offset pendiente
MSYS_NO_PATHCONV=1 kubectl exec -it -n kafka kafka-cli -- /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server lab-kafka-kafka-bootstrap:9092 --topic ventas --group grupo-ventas

Consumir mensajes y que me de una respuesta
MSYS_NO_PATHCONV=1 kubectl exec -it -n kafka kafka-cli -- sh -c '
/opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server lab-kafka-kafka-bootstrap:9092 \
  --topic ventas \
  --group grupo-ventas |
while IFS= read -r line; do
  echo "RECIBIDO: $line"
  if echo "$line" | grep -q "tipo: zapatillas"; then
    echo "COMPRADAS ZAPATILLAS"
  elif echo "$line" | grep -q "tipo: camisetas"; then
    echo "COMPRADA CAMISETA"
  fi
done
'


> Comprobar consumo / offsets / lag

Ver estado del consumer group grupo-ventas
MSYS_NO_PATHCONV=1 kubectl exec -it -n kafka kafka-cli -- /opt/kafka/bin/kafka-consumer-groups.sh --bootstrap-server lab-kafka-kafka-bootstrap:9092 --describe --group grupo-ventas

Consumer group 'grupo-ventas' has no active members.

GROUP           TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID     HOST            CLIENT-ID
grupo-ventas    ventas          0          4               7               3               -               -               -





