#!/bin/bash

set -e

NAMESPACE="elk-stack"
VERSION="8.5.1"

echo "Add and Update Elastic repository"
helm repo add elastic https://helm.elastic.co
helm repo update

echo "Stack Component Installation"
helm install filebeat-kubelet elastic/filebeat \
	--version $VERSION \
	--namespace $NAMESPACE \
	--create-namespace \
	--replace \
	-f values/filebeat-kubelet-logs.yaml

helm install filebeat-pods elastic/filebeat \
	--version $VERSION \
	--namespace $NAMESPACE \
	--create-namespace \
	--replace \
	-f values/filebeat-pod-logs.yaml

helm install filebeat-audit elastic/filebeat \
	--version $VERSION \
	--namespace $NAMESPACE \
	--create-namespace \
	--replace \
	-f values/filebeat-audit-logs.yaml

helm install elasticsearch elastic/elasticsearch \
	--version $VERSION \
	--namespace $NAMESPACE \
	--create-namespace \
	--replace \
	-f values/elasticsearch.yaml
	
helm install logstash elastic/logstash \
	--version $VERSION \
	--namespace $NAMESPACE \
	--create-namespace \
	--timeout=10m \
	--replace \
	-f values/logstash.yaml

helm install kibana elastic/kibana \
	--version $VERSION \
	--namespace $NAMESPACE \
	--create-namespace \
	--replace \
	-f values/kibana.yaml

echo "Finished"
