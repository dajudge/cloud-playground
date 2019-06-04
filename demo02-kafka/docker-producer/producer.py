from time import sleep
from json import dumps
from kafka import KafkaProducer
import os

bootstrap_servers=os.environ['BOOTSTRAP_SERVERS'].split(',')

print('Starting kafka producer: ' + ",".join(bootstrap_servers))
producer = KafkaProducer(bootstrap_servers=bootstrap_servers, value_serializer=lambda x: dumps(x).encode('utf-8'))

for e in range(60):
    data = {'number' : e}
    print('Sending: ' + dumps(data))
    producer.send('numtest', value=data)
    sleep(5)