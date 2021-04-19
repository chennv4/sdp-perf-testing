#!/bin/bash
set -x
namespace=tp

benchmark_pods=( $(kubectl get pod -A | grep benchmark | awk {'print $2'}) )
for pod in "${benchmark_pods[@]}"; do
    kubectl exec -it ${pod} --namespace ${namespace} --  /root/kill-all-java.sh
done
