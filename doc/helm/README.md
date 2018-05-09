# Helm

This document is intended to provide an overview of working with [Helm][helm] for [Kubernetes][k8s-io], and is targetted at using Kubernetes in GKE.

# Helm is not stand-alone

To make use of Helm, you must have a [Kubernetes][k8s-io] cluster. Follow the [dependencies documentation](../installation/dependencies.md)
to ensure you can access your cluster using `kubectl`.

Helm consists of two parts, `helm` client and `tiller` server inside Kubernetes.

# Getting Helm

You can get Helm from the project's [releases page](https://github.com/kubernetes/helm/releases), or follow other options under the official documentation of [Installing Helm](https://docs.helm.sh/using_helm/#installing-helm).

# Initialize Helm and Tiller

## Preparing for Helm with RBAC

> **Note**: Ensure you have kubectl installed and it is up to date. Older versions do not have support for RBAC and will generate errors.

Read [RBAC document](../installation/rbac.md) and if `RBAC` is not enabled in your cluster you can skip this section and proceed.

Helm's Tiller will need to be granted permissions to perform operations. These instructions grant cluster wide permissions, however for more advanced deployments [permissions can be restricted to a single namespace](https://docs.helm.sh/using_helm/#example-deploy-tiller-in-a-namespace-restricted-to-deploying-resources-only-in-that-namespace). To grant access to the cluster, we will create a new `tiller` service account and bind it to the `cluster-admin` role.

Copy the `rbac-config.yaml` file out of the examples:

```
cp doc/helm/examples/rbac-config.yaml rbac-config.yaml
```

Next we need to connect to the cluster and upload the RBAC config.

### Connect to the cluster

You can use:

* [GKE cluster](#connect-to-gke-cluster)
* [Local minikube cluster](#connect-to-local-minikube-cluster)

#### Connect to GKE cluster

The command for connection to the cluster can be obtained from the [Google Cloud Platform Console][gcp-k8s]
by the individual cluster.

Look for the **Connect** button in the clusters list page.

**Or**

Use the command below, filling in your cluster's informtion:

```
gcloud container clusters get-credentials <cluster-name> --zone <zone> --project <project-id>
```

#### Connect to local minikube cluster

If you are doing local development, you can use `minikube` as your
local cluster. If `kubectl cluster-info` is not showing `minikube` as the current
cluster, use `kubectl config set-cluster minikube` to set the active cluster.

### Upload the RBAC config

For GKE, you need to grab the admin credentials:

```
gcloud container clusters describe <cluster-name> --zone <zone> --project <project-id> --format='value(masterAuth.password)'
```

This command will output the admin password. We need the password to authenticate with `kubectl` and create the role.

#### Upload the RBAC config as an admin user

```
kubectl --username=admin --password=xxxxxxxxxxxxxx create -f rbac-config.yaml
```

## Initialize Helm

Deploy Helm Tiller with a service account

```
helm init --service-account tiller
```

If your cluster
previously had Helm/Tiller installed, run the following to ensure that the deployed version of Tiller matches the local Helm version:

```
helm init --upgrade --service-account tiller
```

# Additional Information

The Distribution Team has a [training presentation for Helm Charts](https://docs.google.com/presentation/d/1CStgh5lbS-xOdKdi3P8N9twaw7ClkvyqFN3oZrM1SNw/present).

## Templates

Templating in Helm is done via golang's [text/template][] and [sprig][].

Some information on how all the inner workings behave:
- [Functions and Pipelines][helm-func-pipeline]
- [Subcharts and Globals][helm-subchart-global]

## Tips and Tricks

Helm repository has some additional information on developing with helm in it's
[tips and tricks section](https://github.com/kubernetes/helm/blob/master/docs/charts_tips_and_tricks.md).


[helm]: https://helm.sh
[helm-using]: https://docs.helm.sh/using_helm
[k8s-io]: https://kubernetes.io/
[gcp-k8s]: https://console.cloud.google.com/kubernetes/list

[text/template]: https://golang.org/pkg/text/template/
[sprig]: https://godoc.org/github.com/Masterminds/sprig
[helm-func-pipeline]: https://github.com/kubernetes/helm/blob/master/docs/chart_template_guide/functions_and_pipelines.md
[helm-subchart-global]: https://github.com/kubernetes/helm/blob/master/docs/chart_template_guide/subcharts_and_globals.md