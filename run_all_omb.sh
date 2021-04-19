#!/bin/bash
set -x
namespace=tp
result_dir=results
test_name=round1
rm -rf ${result_dir}
mkdir -p ${result_dir}
benchmark_pods=( $(kubectl get pod -A | grep benchmark | awk {'print $2'}) )
for pod in "${benchmark_pods[@]}"; do
    kubectl exec -it ${pod} --namespace ${namespace} -- sh /root/omb-cleanup.sh > /dev/null 2>&1
    nohup kubectl exec -it ${pod} --namespace ${namespace} -- /root/run-openm.sh 100000 1000 5 2 3 24 0 0 $test_name > ${result_dir}/result.$test_name_$pod.log 2>&1 &
done
