node-name: {{ inventory_hostname }}
service-node-port-range: "443-40000"
cni: "cilium"
cluster-cidr: "10.1.0.0/16"
service-cidr: "10.2.0.0/16"
write-kubeconfig-mode: "0644"
etcd-extra-env:
  - "ETCD_AUTO_COMPACTION_RETENTION=72h"
  - "ETCD_AUTO_COMPACTION_MODE=periodic"
kubelet-arg:
  - "image-gc-low-threshold=99"
  - "image-gc-high-threshold=100"
kube-apiserver-arg:
  - "audit-log-path=/var/log/rke2-apiserver-audit.log"
  - "audit-log-maxage=30"
  - "audit-log-maxbackup=10"
  - "audit-log-maxsize=200"
node-label:
  - "name=rke2-cluster"
tls-san:
  - {{ tls_san_doman_name }}
disable-kube-proxy: true
node-ip: {{ ip }}
advertise-address: {{ ip }}
