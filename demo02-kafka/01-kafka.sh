#! /bin/sh

# Please make sure you have helm installed before running this script.

# Inspired by https://docs.confluent.io/current/installation/installing_cp/cp-helm-charts/docs/index.html

helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts/
helm repo update
helm install confluentinc/cp-helm-charts --namespace kafka --name kafka
