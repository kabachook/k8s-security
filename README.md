# k8s-security

## How to know we are in...

### Docker container

- `/.dockerenv`
- `/entrypoint.sh`,`/app-entrypoint.sh`
- strange hostname looking like hex string `de605c442545`
- PID 1 process is application process or small init system like `dumb-init`
- `cat /proc/self/cgroups` show that we are in cgoup

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

- `cat /proc/self/cgroups` shows that we are in k8s

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

## Test cluster setup

K8s v1.15.0

IPs:

- Router `172.16.0.1`
- Master/control-plane node `172.16.0.2` - `ubuntu0`
- Worker node `172.16.0.3` - `ubuntu1`

Settings:

- CRI - Docker
- CNI - Flannel

## What is open by default

```console
root@ubuntu0:~# lsof -i | grep "*"
kubelet     703            root   30u  IPv6  24098      0t0  TCP *:10250 (LISTEN)
kube-sche  2102            root    3u  IPv6  26128      0t0  TCP *:10251 (LISTEN)
kube-apis  2153            root    3u  IPv6  26160      0t0  TCP *:6443 (LISTEN)
kube-cont  2208            root    3u  IPv6  26190      0t0  TCP *:10252 (LISTEN)
kube-prox  2756            root   10u  IPv6  30091      0t0  TCP *:10256 (LISTEN)
```

```console
root@ubuntu1:~# lsof -i | grep "*"
kubelet    770            root   30u  IPv6  23999      0t0  TCP *:10250 (LISTEN)
kube-prox 2518            root   10u  IPv6  27979      0t0  TCP *:10256 (LISTEN)
```

---

On master node:

- kube-scheduler api on `:10251`

  ```console
  root@ubuntu1:~# curl -sk http://172.16.0.2:10251/metrics
  # Very long output here...
  ```

  Not vesy useful

---

Compared to previous versions of k8s:

- All `kubelet`'s are using auth now
- Can't query anything with default ServiceAccout token in pods

=> Pretty secure(?)

- RBAC enabled by default with webhook mode
- Default ServiceToken on pods has no power
- Metrics do not expose pods ips and metadata, only master

---

However

- No auth logging set up
- No pods interconnection policies
- No run as non-root container enforcment
- No egress traffic restriction to `kube-system` namespace
- ServiceAccout tokens still present on pods (`automountServiceAccountToken:false`)
- No automatic certificate rotation

---

Kubernetes dashboard

No access by default service token => Good

![Dashboard with default token](/imgs/dashboard1.png)
