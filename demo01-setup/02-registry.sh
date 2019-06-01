#! /bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
REGISTRY_NAMESPACE=registry

helm install stable/docker-registry --name registry --namespace $REGISTRY_NAMESPACE
cat $DIR/registry-ingress.yml | sed -e "s|::hostname::|$(/usr/local/bin/playground-hostname registry)|g" | kubectl apply -n $REGISTRY_NAMESPACE -f -