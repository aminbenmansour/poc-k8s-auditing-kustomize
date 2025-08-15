#!/bin/bash

VARIABLES_FILE="../variables.yaml"

# Check if variables.yaml exists
if [[ ! -f "$VARIABLES_FILE" ]]; then
    echo "Error: $VARIABLES_FILE not found!"
    exit 1
fi

# Generate dynamic etcd servers list from all control plane IPs
ETCD_SERVERS=$(yq eval '.controlPlanes[].ip' "$VARIABLES_FILE" | sed 's/^/https:\/\//' | sed 's/$/:2379/' | paste -sd, -)

echo "🔧 Generating audit overlays for all control planes..."
echo "📡 ETCD Servers: $ETCD_SERVERS"

# Read variables and generate manifests for each control plane
yq eval '.controlPlanes[]' $VARIABLES_FILE | while read -r cp; do
  name=$(echo "$cp" | yq eval '.name' -)
  ip=$(echo "$cp" | yq eval '.ip' -)
  cert=$(echo "$cp" | yq eval '.cert' -)
  
  echo "Generating manifest for $name..."
  
  # Create overlay directory
  mkdir -p ../overlays/audit/$name
  
  # Generate kustomization.yaml with replacements
  cat > ../overlays/audit/$name/kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base
patches:
- target:
    kind: Pod
    name: kube-apiserver
  patch: |
    - op: replace
      path: /metadata/annotations/kubeadm.kubernetes.io~1kube-apiserver.advertise-address.endpoint
      value: "${ip}:6443"
    - op: replace
      path: /spec/containers/0/command/1
      value: "--advertise-address=${ip}"
    - op: replace
      path: /spec/containers/0/command/15
      value: "--etcd-certfile=/etc/ssl/etcd/ssl/${cert}.pem"
    - op: replace
      path: /spec/containers/0/command/17
      value: "--etcd-keyfile=/etc/ssl/etcd/ssl/${cert}-key.pem"
    - op: replace
      path: /spec/containers/0/command/18
      value: "--etcd-servers=${ETCD_SERVERS}"
    - op: replace
      path: /spec/containers/0/livenessProbe/httpGet/host
      value: "${ip}"
    - op: replace
      path: /spec/containers/0/readinessProbe/httpGet/host
      value: "${ip}"
    - op: replace
      path: /spec/containers/0/startupProbe/httpGet/host
      value: "${ip}"
EOF
  
  # Generate the final manifest using kustomize
  echo "🏗️  Building manifest for $name..."
  kubectl kustomize "../overlays/audit/$name" > "../manifests/kube-apiserver-$name.yaml"
  
  echo "✅ Generated manifests/kube-apiserver-$name.yaml"
done

echo "🎉 All audit overlays generated successfully!"

