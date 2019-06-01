#! /bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

docker build $DIR/docker-consumer -t registry.192.168.39.109.xip.io:80/demo02/consumer
docker push registry.192.168.39.109.xip.io:80/demo02/consumer
