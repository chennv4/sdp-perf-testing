#!/bin/bash
set -x
namespace=tp
benchmark_pods=( $(kubectl get pod -A | grep benchmark | awk {'print $2'}) )
for pod in "${benchmark_pods[@]}"; do
    kubectl exec -it ${pod} -n ${namespace} -- rm -f /usr/local/share/ca-certificates/detroit.crt
    kubectl exec -it ${pod} -n ${namespace} -- rm -f /usr/local/share/ca-certificates/sdp-registry.crt
    kubectl exec -it ${pod} -n ${namespace} -- update-ca-certificates -f
    kubectl exec -it ${pod} -n ${namespace} -- /root/omb-prep.sh
    kubectl cp -n ${namespace} /home/ubuntu/desdp/certs/sdp-registry.crt ${pod}:/usr/local/share/ca-certificates/
    kubectl cp -n ${namespace} /home/ubuntu/perf/pravega.yaml ${pod}:/tmp/test/pravega.yaml
    kubectl exec -it ${pod} -n ${namespace} -- /root/update-crt-and-keycloak.sh
    kubectl -n ${namespace} exec -it ${pod} -- bash -c 'sed -i "s/JVM_MEM=\"-Xms4G -Xmx4G -XX:+UseG1GC\"/JVM_MEM=\"-Xms16G -Xmx16G -XX:+UseG1GC -XX:MaxGCPauseMillis=10 -XX:+ParallelRefProcEnabled -XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+AggressiveOpts -XX:+DoEscapeAnalysis -XX:ParallelGCThreads=32 -XX:ConcGCThreads=32 -XX:G1NewSizePercent=50 -XX:+DisableExplicitGC -XX:-ResizePLAB -XX:+PerfDisableSharedMem -XX:-UseBiasedLocking\"/g" /opt/openmessaging-benchmark/bin/benchmark'
    kubectl -n ${namespace} exec -it ${pod} -- bash -c 'sed -i "s/DEFAULT_JVM_OPTS=\"\"/DEFAULT_JVM_OPTS=\"-Xms16G -Xmx16G -XX:+UseG1GC -XX:MaxGCPauseMillis=10 -XX:+ParallelRefProcEnabled -XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+AggressiveOpts -XX:+DoEscapeAnalysis -XX:ParallelGCThreads=32 -XX:ConcGCThreads=32 -XX:G1NewSizePercent=50 -XX:+DisableExplicitGC -XX:-ResizePLAB -XX:+PerfDisableSharedMem -XX:-UseBiasedLocking\"/g" /opt/pravega-benchmark/bin/pravega-benchmark'
done
