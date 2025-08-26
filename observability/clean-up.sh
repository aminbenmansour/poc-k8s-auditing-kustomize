#!/bin/bash

NAMESPACE="elk-stack"

helm list --short --namespace $NAMESPACE | xargs helm uninstall --namespace $NAMESPACE

kubectl delete all --all -n=$NAMESPACE --force --grace-period=0
kubectl delete ns $NAMESPACE --force --grace-period=0
