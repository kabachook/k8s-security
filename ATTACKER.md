# Attacker's guide to kubernetes

## General

Typical workflow:

Get cluster access (internal, RCE on container, etc)
⬇️
Check for serviceaccount and its privileges
⬇️
Scan for services and try to get other accounts
🔄
⬇️
Get admin account or an account with sufficient privileges
⬇️
Execute code on cluster/steal data

### ServiceAccount

By default on every container a "default service account" is mounted to dir `/run/secrets/kubernetes.io/serviceaccount`

By default it has no value, but admins may give it permissions, e.g Helm, Dashboard

Check if account can get secrets, so you can compromise other accounts with different privileges

---

How to distinguish account token/keys?

ServiceAccount can be in forms:

- CA certificate + JWT token (usually on containers, `Webhook` authn)
- CA certificate + client certificate + client key (usually in `.yaml` files as base64encoded strings, `TLS` authn)

With any form you can query `apiserver` by http with, e.g `curl`. See [readme](./README.md) for second form usage examples, and k8s docs for `Webhook`.

## How to know we are in...

### Docker container

- `/.dockerenv`
- `/entrypoint.sh`,`/app-entrypoint.sh`
- strange hostname looking like hex string `de605c442545`
- PID 1 process is application process or small init system like `dumb-init`
- `cat /proc/self/cgroup` shows that we are in cgroup

  Example:

  ```
  root@de605c442545:/# cat /proc/self/cgroup
  12:cpuset:/docker/de605c4425454a410b82da7b6ceeb73ba15ed4adab5c3ae10602b648ba296225
  11:freezer:/docker/de605c4425454a410b82da7b6ceeb73ba15ed4adab5c3ae10602b648ba296225
  10:perf_event:/docker/de605c4425454a410b82da7b6ceeb73ba15ed4adab5c3ae10602b648ba296225
  9:rdma:/
  8:net_cls,net_prio:/docker/de605c4425454a410b82da7b6ceeb73ba15ed4adab5c3ae10602b648ba296225
  7:pids:/docker/de605c4425454a410b82da7b6ceeb73ba15ed4adab5c3ae10602b648ba296225
  6:memory:/docker/de605c4425454a410b82da7b6ceeb73ba15ed4adab5c3ae10602b648ba296225
  5:hugetlb:/docker/de605c4425454a410b82da7b6ceeb73ba15ed4adab5c3ae10602b648ba296225
  4:blkio:/docker/de605c4425454a410b82da7b6ceeb73ba15ed4adab5c3ae10602b648ba296225
  3:cpu,cpuacct:/docker/de605c4425454a410b82da7b6ceeb73ba15ed4adab5c3ae10602b648ba296225
  2:devices:/docker/de605c4425454a410b82da7b6ceeb73ba15ed4adab5c3ae10602b648ba296225
  1:name=systemd:/docker/de605c4425454a410b82da7b6ceeb73ba15ed4adab5c3ae10602b648ba296225
  0::/system.slice/docker.service
  ```

### K8s pod

- docker signs if it is CRI
- hostname like `<app-name>-[a-f0-9]{10}-[a-z0-9]{5}`

  Example: `tomcat-55c4cc5fcd-7l6x4`

- `cat /proc/self/cgroup` shows that we are in k8s

  Example:

  ```
  11:pids:/kubepods/burstable/pode060d9f5-4f41-4153-8daf-4a7ee2a7eaad/4088e78945f24d32ca3e1b09f097704c9c92e70f525a553fef8da2e6c7f333fd
  10:cpuset:/kubepods/burstable/pode060d9f5-4f41-4153-8daf-4a7ee2a7eaad/4088e78945f24d32ca3e1b09f097704c9c92e70f525a553fef8da2e6c7f333fd
  9:blkio:/kubepods/burstable/pode060d9f5-4f41-4153-8daf-4a7ee2a7eaad/4088e78945f24d32ca3e1b09f097704c9c92e70f525a553fef8da2e6c7f333fd
  8:memory:/kubepods/burstable/pode060d9f5-4f41-4153-8daf-4a7ee2a7eaad/4088e78945f24d32ca3e1b09f097704c9c92e70f525a553fef8da2e6c7f333fd
  7:hugetlb:/kubepods/burstable/pode060d9f5-4f41-4153-8daf-4a7ee2a7eaad/4088e78945f24d32ca3e1b09f097704c9c92e70f525a553fef8da2e6c7f333fd
  6:perf_event:/kubepods/burstable/pode060d9f5-4f41-4153-8daf-4a7ee2a7eaad/4088e78945f24d32ca3e1b09f097704c9c92e70f525a553fef8da2e6c7f333fd
  5:freezer:/kubepods/burstable/pode060d9f5-4f41-4153-8daf-4a7ee2a7eaad/4088e78945f24d32ca3e1b09f097704c9c92e70f525a553fef8da2e6c7f333fd
  4:cpu,cpuacct:/kubepods/burstable/pode060d9f5-4f41-4153-8daf-4a7ee2a7eaad/4088e78945f24d32ca3e1b09f097704c9c92e70f525a553fef8da2e6c7f333fd
  3:net_cls,net_prio:/kubepods/burstable/pode060d9f5-4f41-4153-8daf-4a7ee2a7eaad/4088e78945f24d32ca3e1b09f097704c9c92e70f525a553fef8da2e6c7f333fd
  2:devices:/kubepods/burstable/pode060d9f5-4f41-4153-8daf-4a7ee2a7eaad/4088e78945f24d32ca3e1b09f097704c9c92e70f525a553fef8da2e6c7f333fd
  1:name=systemd:/kubepods/burstable/pode060d9f5-4f41-4153-8daf-4a7ee2a7eaad/4088e78945f24d32ca3e1b09f097704c9c92e70f525a553fef8da2e6c7f333fd
  ```

  But, there is an option that k8s controls cgroups via systemd

- run `mount`

  Example:

  ```
  ...
  cgroup on /sys/fs/cgroup/cpu,cpuacct type cgroup (ro,nosuid,nodev,noexec,relatime,cpu,cpuacct)
  cgroup on /sys/fs/cgroup/blkio type cgroup (ro,nosuid,nodev,noexec,relatime,blkio)
  cgroup on /sys/fs/cgroup/memory type cgroup (ro,nosuid,nodev,noexec,relatime,memory)
  ...
  tmpfs on /run/secrets/kubernetes.io/serviceaccount type tmpfs (ro,relatime)
  ```

## Addon attacks

Prerequisite:

- dns queries are not blocked
- no network policy blocking connection

### Helm

Given no TLS was configured you can use Helm as an admin

1. Download helm cli

```console
$ wget https://get.helm.sh/helm-v2.14.3-linux-amd64.tar.gz
$ tar xfv helm-v2.14.3-linux-amd64.tar.gz
```

2. Use helm

```console
$ ./helm --host tiller-deploy.kube-system.svc.cluster.local:44134
```

[Demo](./imgs/helm_pwn.svg)

### Dashboard

If **`cluster-admin` role** is given to dashboard serviceaccount and `--enable-skip-login` is set, then you can bypass login in kubernetes dashboard

1. Just go to `https://kubernetes-dashboard.kubernetes-dashboard.svc.cluster.local`
2. Click `skip` button

## Container attacks

Never forget about typical container(Docker) attacks:

- Mounted `docker.sock` => root on node
- Mounted `/var/lib/kubelet/` dir => kubelet account (get secrets, pods _by name_)
- Pod running on master => direct exposure to `etcd`
