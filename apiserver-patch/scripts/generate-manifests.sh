#!/bin/bash

# Read variables and generate manifests for each control plane
yq eval '.controlPlanes[]' apiserver-patch/variables.yaml | while read -r cp; do
  name=$(echo "$cp" | yq eval '.name' -)
  ip=$(echo "$cp" | yq eval '.ip' -)
  cert=$(echo "$cp" | yq eval '.cert' -)
  
  echo "Generating manifest for $name..."
  
  # Create overlay directory
  mkdir -p ../overlays/$name
  
  # Generate kustomization.yaml with replacements
  cat > ../overlays/$name/kustomization.yaml << EOF
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
      path: /spec/containers/0/livenessProbe/httpGet/host
      value: "${ip}"
    - op: replace
      path: /spec/containers/0/readinessProbe/httpGet/host
      value: "${ip}"
    - op: replace
      path: /spec/containers/0/startupProbe/httpGet/host
      value: "${ip}"
EOF
  
  # Generate the final manifest
  kustomize build overlays/$name > manifests/kube-apiserver-$name.yaml
done
