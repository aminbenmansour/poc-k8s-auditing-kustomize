#!/bin/bash

set -e

NAMESPACE="elk-stack"
VERSION="8.5.1"

# add and update elastic repo
helm repo add elastic https://helm.elastic.co
helm repo update

# components installation
helm install filebeat elastic/filebeat \
	--version $VERSION \
	--namespace $NAMESPACE \
	--create-namespace \
	--replace \
	-f values/filebeat.yaml

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
