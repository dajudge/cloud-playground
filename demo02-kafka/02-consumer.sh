#! /bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DOCKER_REGISTRY="$(/usr/local/bin/playground-hostname registry):80"
TIMESTAMP=$(date +%s)
CONSUMER_IMAGE="${DOCKER_REGISTRY}/demo02/consumer:${TIMESTAMP}"
REGISTRY_IP=$(kubectl get -n registry -o jsonpath="{.spec.clusterIP}" svc/registry-docker-registry)
INTERNAL_IMAGE="${REGISTRY_IP}:5000/demo02/consumer:${TIMESTAMP}"

docker build $DIR/docker-consumer -t ${CONSUMER_IMAGE}
docker push ${CONSUMER_IMAGE}
cat $DIR/consumer-pod.yml | sed -e "s|::image::|${INTERNAL_IMAGE}|g" | kubectl apply -n kafka -f -
