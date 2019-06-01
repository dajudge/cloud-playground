#! /bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Install helm as described in https://github.com/helm/helm/blob/master/docs/rbac.md
kubectl apply -f $DIR/rbac-config.yml
helm init --service-account tiller --history-max 200 --upgrade