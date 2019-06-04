import os
from kafka import KafkaConsumer
from json import loads

bootstrap_servers=os.environ['BOOTSTRAP_SERVERS'].split(',')

print('Starting kafka consumer: ' + ",".join(bootstrap_servers))
consumer = KafkaConsumer(
    'numtest',
     bootstrap_servers=bootstrap_servers,
     auto_offset_reset='earliest',
     enable_auto_commit=True,
     group_id='demo02-group',
     value_deserializer=lambda x: loads(x.decode('utf-8')))

for message in consumer:
    print('Received {}'.format(message.value))