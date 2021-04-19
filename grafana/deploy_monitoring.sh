#!/bin/bash
node_ip=10.157.10.45
dir=/home/ubuntu/perf/grafana

echo "------ Deploy grafana and influxdb ------"
cd $dir
kubectl create -f ./grafana-manifests/influx-deployment.yaml
kubectl expose deployment prvg-influxdb --port=8086 --target-port=8086 --type=ClusterIP

kubectl create -f ./grafana-manifests/grafana-datasource-config.yaml
kubectl create -f ./grafana-manifests/grafana-dashboard-config.yaml
kubectl create -f ./grafana-manifests/grafana-dashboard.yaml
kubectl create -f ./grafana-manifests/grafana-deployment.yaml
kubectl expose deployment prvg-grafana --port=3000 --type=NodePort
grafana_node_port=`kubectl get service prvg-grafana -o jsonpath='{.spec.ports[0].nodePort}'`

echo "------ Deploy Prometheus ------"
helm repo add stable https://charts.helm.sh/stable
helm repo add jetstack https://charts.jetstack.io
#For adding prometheus images to the devops repo use command:
#for i in prom/node-exporter:v1.0.1 prom/pushgateway:v1.2.0 prom/prometheus:v2.20.1 prom/alertmanager:v0.21.0 jimmidyson/configmap-reload:v0.4.0; do docker pull ${i} && docker tag ${i} devops-repo.isus.emc.com:8116/${i} && docker push devops-repo.isus.emc.com:8116/${i}; done

helm install prvg-prometheus --set server.extraFlags="{web.enable-lifecycle,web.enable-admin-api}" --set server.global.scrape_interval=10s --set alertmanager.enabled=false stable/prometheus

for i in {1..18};do kubectl -n nautilus-pravega patch pod nautilus-bookie-${i} -p '{"metadata": {"annotations":{"prometheus.io/scrape":"true","prometheus.io/path":"/metrics","prometheus.io/port":"8080"}}}';done

echo "Grafana address: http://${node_ip}:${grafana_node_port}"

