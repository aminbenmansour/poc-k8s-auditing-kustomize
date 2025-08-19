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

# Generate manifests first
./generate-audit.sh

echo "🔄 Deploying to control planes..."

# Deploy to each control plane
yq eval '.controlPlanes[]' $VARIABLES_FILE | while read -r cp; do
  name=$(echo "$cp" | yq eval '.name' -)
  ip=$(echo "$cp" | yq eval '.ip' -)
  user=$(echo "$cp" | yq eval '.user // "root"' -)
  
  echo "  → Deploying to $name ($ip)..."
  scp "../audit-policy.yaml" "$user@$ip:/etc/kubernetes/audit-policy.yaml"
  scp "../manifests/kube-apiserver-$name.yaml" "$user@$ip:/etc/kubernetes/manifests/kube-apiserver.yaml"
  echo "  ✅ $name deployed"
done

echo "🎉 All control planes updated with audit configuration!"
