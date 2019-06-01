#! /bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Please make sure you have helm installed before running this script.

RABBITMQ_NAMESPACE=rabbitmq

helm install stable/rabbitmq -f $DIR/values.yml --name rabbitmq --namespace ${RABBITMQ_NAMESPACE}
cat $DIR/rabbitmq-ingress.yml | sed -e "s|::hostname::|$(/usr/local/bin/playground-hostname rabbitmq)|g" | kubectl apply -n ${RABBITMQ_NAMESPACE} -f -
cat $DIR/rabbitmq-config.yml | kubectl apply -n ${RABBITMQ_NAMESPACE} -f -