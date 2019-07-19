# Log

## Setup cluster

1. Setup docker on master and node

2. Setup cluster

```console
root@ubuntu0:~# kubeadm init
```

```console
root@ubuntu1:~# kubelet join ...
```

## Dashboard

Dashboard itself:

```console
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
```
