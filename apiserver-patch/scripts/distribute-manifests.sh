#!/bin/bash
set -e

VARIABLES_FILE="../variables.yaml"

# Check if variables.yaml exists
if [[ ! -f "$VARIABLES_FILE" ]]; then
    echo "Error: $VARIABLES_FILE not found!"
    exit 1
fi

mkdir -p ../manifests

echo "🚀 Deploying kube-apiserver to all control planes..."

yq eval '.controlPlanes[]' $VARIABLES_FILE | while read -r cp; do
  name=$(echo "$cp" | yq eval '.name' -)
  user=$(echo "$user" | yq eval '.user' -)
  ip=$(echo "$cp" | yq eval '.ip' -)
  echo "  → $name ($ip)..."
  mkdir -p ../overlays/audit/$name 
  kubectl kustomize ../overlays/audit/$name > ../manifests/kube-apiserver-$name.yaml
  echo "  ✅ $name kustomization built"
  scp "../manifests/kube-apiserver-$name.yaml" "$user@$ip:/etc/kubernetes/manifests/kube-apiserver.yaml"
  echo "  ✅ $name deployed"
done

echo "🎉 All control planes updated!"
