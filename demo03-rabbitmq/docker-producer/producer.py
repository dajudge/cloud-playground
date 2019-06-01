import pika
from time import sleep

rabbitmq_server='rabbitmq.rabbitmq.svc'

print('Starting RabbitMQ producer: ' + rabbitmq_server)

credentials = pika.PlainCredentials('user', 's3cr3t')
connection = pika.BlockingConnection(pika.ConnectionParameters(rabbitmq_server, 5672, '/', credentials))
channel = connection.channel()

for e in range(60):
    print('Sending: ' + str(e))
    channel.basic_publish(exchange='', routing_key='playground', body=str(e))
    sleep(5)

connection.close()

