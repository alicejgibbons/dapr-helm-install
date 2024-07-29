## Helm values Readme: https://github.com/dapr/dapr/blob/master/charts/dapr/README.md
### Helm install Dapr: first time
helm install dapr dapr/dapr --version=1.13.5 --namespace dapr-system --create-namespace --values values.yaml --wait

### Helm install Dapr with custom container images. Push the following images to the repo of your choice, and still use oss helm chart.
### Can also use the ghcr images --set global.registry=ghcr.io/dapr
# docker.io/daprio/operator:1.13.5 -> alicejgibbons/operator:1.13.5 
# docker.io/daprio/placement:1.13.5 -> alicejgibbons/placement:1.13.5
# docker.io/daprio/sentry:1.13.5 -> alicejgibbons/sentry:1.13.5
# docker.io/daprio/injector:1.13.5 -> alicejgibbons/injector:1.13.5
# docker.io/daprio/daprd:1.13.5 -> alicejgibbons/daprd:1.13.5
export CUSTOM_REGISTRY=alicejgibbons
helm repo update
helm install dapr dapr/dapr --version=1.13.5 --namespace dapr-system --create-namespace --set global.ha.enabled=true --set dapr_operator.watch_interval=3m --set global.registry=alicejgibbons --wait

### Custom helm chart:
helm repo add dapr https://dapr.github.io/helm-charts/
helm repo add dapr http://helm.custom-domain.com/dapr/dapr/ --username=xxx --password=xxx

### Helm uninstall
helm uninstall dapr -n dapr-system

### Helm upgrade instructions
# https://docs.dapr.io/operations/hosting/kubernetes/kubernetes-upgrade/#helm
# IMPORTANT: Upgrade only one minor version of Dapr at a time ensuring you update the CRDs first.
# IMPORTANT: the CRD installation instructions will be different for different versions of Dapr. This is specific to 1.13.5, change the version in the Dapr docs for other upgrades
kubectl replace -f https://raw.githubusercontent.com/dapr/dapr/v1.13.5/charts/dapr/crds/components.yaml
kubectl replace -f https://raw.githubusercontent.com/dapr/dapr/v1.13.5/charts/dapr/crds/configuration.yaml
kubectl replace -f https://raw.githubusercontent.com/dapr/dapr/v1.13.5/charts/dapr/crds/subscription.yaml
kubectl apply -f https://raw.githubusercontent.com/dapr/dapr/v1.13.5/charts/dapr/crds/resiliency.yaml
kubectl apply -f https://raw.githubusercontent.com/dapr/dapr/v1.13.5/charts/dapr/crds/httpendpoints.yaml

helm ls -A
helm upgrade --install dapr dapr/dapr --version=1.13.5 --values values.yaml --namespace dapr-system --wait

# Watch the pods in the dapr-system namespace
kubectl get po -n dapr-system -w

# Rollout all Dapr sidecars in your application namespace to ensure that they get the new version
kubectl rollout restart deploy

### Rollback to the previous version of Dapr deployed.
helm ls -A
helm rollback dapr {REVISION-1} -n dapr-system 
