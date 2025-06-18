apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rke2-cilium
  namespace: kube-system
spec:
  valuesContent: |-
    kubeProxyReplacement: true
    k8sServiceHost: {{ ip }}
    k8sServicePort: 6443 
    devices: {{ network_interface }}
    operator:
      replicas: 1
    {%  if deploy_hubble %}
    hubble:
      enabled: true
      relay:
        enabled: true
      ui:
        enabled: true
    {%  endif %}
