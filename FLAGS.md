# Kubernetes flags for securing cluster

By default `kubeadm` bootstraps all these flags, but it may differ in other distributions like `kops`, `GKE`, etc

> Flags values are default `kubeadm` installation, check if it works on your cluster beforehand

## TLS authentication

Flags needed for TLS to work

### kube-apiserver

- `--client-ca-file=/etc/kubernetes/pki/ca.crt`
- `--etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt`
- `--etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt`
- `--etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key`
- `--etcd-servers=https://127.0.0.1:2379`
- `--insecure-port=0`
- `--kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt`
- `--kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key`
- `--proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt`
- `--proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key`
- `--requestheader-allowed-names=front-proxy-client`
- `--requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt`
- `--requestheader-extra-headers-prefix=X-Remote-Extra-`
- `--requestheader-group-headers=X-Remote-Group`
- `--requestheader-username-headers=X-Remote-User`
- `--secure-port=6443`
- `--service-account-key-file=/etc/kubernetes/pki/sa.pub`
- `--tls-cert-file=/etc/kubernetes/pki/apiserver.crt`
- `--tls-private-key-file=/etc/kubernetes/pki/apiserver.key`

### kubelet

By default `kubeadm` installation uses two config files:

- `--config=/var/lib/kubelet/config.yaml` - `kubelet` configuration

```yaml
authentication:
  x509:
    clientCAFile: /etc/kubernetes/pki/ca.crt
```

should be in file

- `--kubeconfig=/etc/kubernetes/kubelet.conf` - `kubelet` credentials

```yaml
apiVersion: v1
clusters:
  - cluster:
      certificate-authority-data: LS0tLS1C...
      server: https://172.16.0.2:6443
    name: default-cluster
---
users:
  - name: default-auth
    user:
      client-certificate: /var/lib/kubelet/pki/kubelet-client-current.pem
      client-key: /var/lib/kubelet/pki/kubelet-client-current.pem
```

`client-certificate` and `client-key` should be set

> P.S keys in yaml files could be replaced with normal command line `--` options

### etcd

- `--cert-file=/etc/kubernetes/pki/etcd/server.crt`
- `--client-cert-auth=true`
- `--key-file=/etc/kubernetes/pki/etcd/server.key`
- `--listen-client-urls=https://127.0.0.1:2379,https://172.16.0.2:2379`
- `--listen-peer-urls=https://172.16.0.2:2380`
- `--peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt`
- `--peer-client-cert-auth=true`
- `--peer-key-file=/etc/kubernetes/pki/etcd/peer.key`
- `--peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt`
- `--trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt`

> `kubeadm` issues separate certificates for health check probes
>
> Probe container command:
>
> `ETCDCTL_API=3 etcdctl --endpoints=https://[127.0.0.1]:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt --key=/etc/kubernetes/pki/etcd/healthcheck-client.key get foo`

### kube-controller-manager

- `--authentication-kubeconfig=/etc/kubernetes/controller-manager.conf`
- `--authorization-kubeconfig=/etc/kubernetes/controller-manager.conf`
- `--client-ca-file=/etc/kubernetes/pki/ca.crt`
- `--cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt`
- `--cluster-signing-key-file=/etc/kubernetes/pki/ca.key`
- `--kubeconfig=/etc/kubernetes/controller-manager.conf`
- `--requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt`
- `--root-ca-file=/etc/kubernetes/pki/ca.crt`
- `--service-account-private-key-file=/etc/kubernetes/pki/sa.key`
- `--use-service-account-credentials=true`

`/etc/kubernetes/controller-manager.conf` should be present with credentials

### kube-scheduler

- `--kubeconfig=/etc/kubernetes/scheduler.conf`

`/etc/kubernetes/scheduler.conf` should be present with credentials

## Authorization

Flags needed for authorization to work

### kube-apiserver

- `--authorization-mode=Node,RBAC`

### kubelet

Webhook is needed for authorization to work on `kubelet`

```yaml
authorization:
  mode: Webhook
```
