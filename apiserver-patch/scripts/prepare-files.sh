#! /bin/bash

# if [ -z "$1" ] || [ -z "$2" ]; then
if [ $# -lt 2 ]; then
  echo "Usage: $0 <CONTROLPLANE_NODE_USER> <CONTROLPLANE_NODE_IP>"
  exit 1
fi

CONTROLPLANE_NODE_USER=$1
CONTROLPLANE_NODE_IP=$2

echo "== Operating on control-plane: $CONTROLPLANE_NODE_IP =="

echo "Transfer audit policy file"
kubectl kustomize ../overlays/audit/ > kube-apiserver.yaml


echo "Build kube-apiserver resource for auditing with Kustomize"
kubectl kustomize ../overlays/audit/ > kube-apiserver.yaml

echo "Apply kube-apiserver configuration"
scp kube-apiserver.yaml $CONTROLPLANE_NODE_USER@$CONTROLPLANE_NODE_IP:/etc/kubernetes/manifests/ && rm kube-apiserver.yaml
