# Installation Guide

## Prerequisite Generic Deployment Command

!!! attention
    The default configuration watches Ingress object from *all the namespaces*.
    To change this behavior use the flag `--watch-namespace` to limit the scope to a particular namespace.

!!! warning
    If multiple Ingresses define different paths for the same host, the ingress controller will merge the definitions.

!!! attention
    If you're using GKE you need to initialize your user as a cluster-admin with the following command:

```console
kubectl create clusterrolebinding cluster-admin-binding \
--clusterrole cluster-admin \
--user $(gcloud config get-value account)
```

The following **Mandatory Command** is required for all deployments except for AWS. See below for the AWS version.

```console
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml
```

### Provider Specific Steps

There are cloud provider specific yaml files.




##### Network Load Balancer (NLB)

This type of load balancer is supported since v1.10.0 as an ALPHA feature.

```console
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/aws/service-nlb.yaml
```


#### Bare-metal

Using [NodePort](https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport):

```console
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/baremetal/deploy.yaml
```

!!! tip
    For extended notes regarding deployments on bare-metal, see [Bare-metal considerations](https://github.com/kubernetes/ingress-nginx/blob/main/docs/deploy/baremetal.md).

### Verify installation

To check if the ingress controller pods have started, run the following command:

```console
kubectl get pods --all-namespaces -l app.kubernetes.io/name=ingress-nginx --watch
```

Once the operator pods are running, you can cancel the above command by typing `Ctrl+C`.
Now, you are ready to create your first ingress.

### Detect installed version

To detect which version of the ingress controller is running, exec into the pod and run `nginx-ingress-controller version` command.

```console
POD_NAMESPACE=ingress-nginx
POD_NAME=$(kubectl get pods -n $POD_NAMESPACE -l app.kubernetes.io/component=controller -o jsonpath='{.items[0].metadata.name}')

kubectl exec -it $POD_NAME -n $POD_NAMESPACE -- /nginx-ingress-controller --version
```

## Using Helm

NGINX Ingress controller can be installed via [Helm](https://helm.sh/) using the chart [ingress-nginx/ingress-nginx](https://kubernetes.github.io/ingress-nginx).
Official documentation is [here](https://kubernetes.github.io/ingress-nginx/deploy/#using-helm)

To install the chart with the release name `my-nginx`:

```console
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install my-nginx ingress-nginx/ingress-nginx
```

Detect installed version:

```console
POD_NAME=$(kubectl get pods -l app.kubernetes.io/name=ingress-nginx -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $POD_NAME -- /nginx-ingress-controller --version
```
