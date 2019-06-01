from time import sleep
from json import dumps
from kafka import KafkaProducer

bootstrap_servers='kafka-cp-kafka.kafka.svc:9092'
print('Starting kafka producer: ' + bootstrap_servers)
producer = KafkaProducer(bootstrap_servers=[bootstrap_servers], value_serializer=lambda x: dumps(x).encode('utf-8'))
for e in range(60):
    data = {'number' : e}
    print(dumps(data))
    producer.send('numtest', value=data)
    sleep(5)