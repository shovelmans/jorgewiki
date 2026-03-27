from kafka import KafkaProducer
import time

producer = KafkaProducer(
    bootstrap_servers='lab-kafka-kafka-bootstrap:9092',
    value_serializer=lambda v: v.encode('utf-8')
)

contador = 1

while True:
    mensaje = f"Mensaje para kafka numero {contador}"
    
    producer.send('topic-prueba', mensaje)
    producer.flush()

    print(f"Enviado: {mensaje}")

    contador += 1
    time.sleep(60)