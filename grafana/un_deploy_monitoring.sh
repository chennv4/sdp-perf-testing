#!/bin/bash
node_ip=10.157.10.45
dir=/home/ubuntu/perf/grafana

echo "------ Deploy grafana and influxdb ------"
cd $dir
kubectl delete -f ./grafana-manifests/influx-deployment.yaml

kubectl delete -f ./grafana-manifests/grafana-datasource-config.yaml
kubectl delete -f ./grafana-manifests/grafana-dashboard-config.yaml
kubectl delete -f ./grafana-manifests/grafana-dashboard.yaml
kubectl delete -f ./grafana-manifests/grafana-deployment.yaml

helm del prvg-prometheus


