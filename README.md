# k8s-security

## How to know we are in...

### Docker container

- `/.dockerenv`
- `/entrypoint.sh`,`/app-entrypoint.sh`
- strange hostname looking like hex string `de605c442545`
- PID 1 process is application process or small init system like `dumb-init`
- `cat /proc/self/cgroups` shows that we are in cgoup

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

  But, there is an option that k8s controls cgroups via systemd

## ENV

K8s v1.15.0

IPs:

- Router `172.16.0.1`
- Master/control-plane node `172.16.0.2` - `ubuntu0`
- Worker node `172.16.0.3` - `ubuntu1`

Settings:

- CRI - Docker 18.09.7
- CNI - Flannel 0.11.0

---

## What is open by default

Master:

```console
root@ubuntu0:~# lsof -i | grep "*"
kubelet     703            root   30u  IPv6  24098      0t0  TCP *:10250 (LISTEN)
kube-sche  2102            root    3u  IPv6  26128      0t0  TCP *:10251 (LISTEN)
kube-apis  2153            root    3u  IPv6  26160      0t0  TCP *:6443 (LISTEN)
kube-cont  2208            root    3u  IPv6  26190      0t0  TCP *:10252 (LISTEN)
kube-prox  2756            root   10u  IPv6  30091      0t0  TCP *:10256 (LISTEN)
```

Node:

```console
root@ubuntu1:~# lsof -i | grep "*"
kubelet    770            root   30u  IPv6  23999      0t0  TCP *:10250 (LISTEN)
kube-prox 2518            root   10u  IPv6  27979      0t0  TCP *:10256 (LISTEN)
```

**Master**

| Port  | Component               | Description                                                      | How to query                                      |
| ----- | ----------------------- | ---------------------------------------------------------------- | ------------------------------------------------- |
| 6443  | kube-apiserver          | k8s API for user interaction                                     | `kubectl ...` or `curl https://ip:6443/`          |
| 10250 | kubelet                 | k8s node agent                                                   | `curl https://ip:10250/{metrics,stats,logs,spec}` |
| 10251 | kube-scheduler          | k8s pod sheduler, exposes some metrics in prometheus format      | `curl http://ip:10251/metrics`                    |
| 10252 | kube-controller-manager | k8s control loop to reach desired cluster state, exposes metrics | `curl http://ip:10252/merrics`                    |
| 10256 | kube-proxy              | k8s proxy for port forwarding                                    | -                                                 |

**Nodes**

| Port  | Component  | Description                   | How to query                                      |
| ----- | ---------- | ----------------------------- | ------------------------------------------------- |
| 10250 | kubelet    | k8s node agent                | `curl https://ip:10250/{metrics,stats,logs,spec}` |
| 10256 | kube-proxy | k8s proxy for port forwarding | -                                                 |

---

- kube-scheduler api on `:10251`

  ```console
  root@ubuntu1:~# curl -sk http://172.16.0.2:10251/metrics
  # Very long output here...
  # TYPE kubernetes_build_info gauge
  kubernetes_build_info{buildDate="2019-06-19T16:32:14Z",compiler="gc",gitCommit="e8462b5b5dc2584fdcd18e6bcfe9f1e4d970a529",gitTreeState="clean",gitVersion="v1.15.0",goVersion="go1.12.5",major="1",minor="15",platform="linux/amd64"} 1
  ```

  Same for `10252` port

  Not vesy useful, but get k8s version always. Maybe some other stuff on previous versions

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

## Config files

For both master and node

- `/etc/kubernetes/*.conf` - credentials for apiserver of componenets(including cluster admin config!)
- `/etc/kubernetes/manifests/*.yaml` - cluster components(etcd, apiserver, control-manager, scheduler) configs
- `/etc/kubernetes/pki/**/*` - certs and keys for all componenets
- `/var/lib/kubelet/**/*` - kubelet files

Everything should be readable only for root and k8s admin user(if present)
Exception: all `*.crt` files can be public

By default only readable for root

---

## Secret files

Must be readable only for root

### Master

- `/etc/kubernetes/admin.conf` - cluster admin credentials
- `/etc/kubernetes/{kubelet,control-manager,scheduler}.conf` - componenets credentials
- `/etc/kubernetes/pki` - PKI folder, contains keys and CA, keys for apiserver and other componenets
- `/var/lib/kubelet/config.yaml` - kubelet config (includes CA path)

### Nodes

- `/var/lib/kubelet/config.yaml` - kubelet config (includes CA path)

### Pods

- `/var/run/secrets/kubernetes.io/serviceaccount/*` - default ServiceAccount token, and apiserver CA cert

---

## Kubernetes dashboard

No access by default service token => Good

![Dashboard with default token](/imgs/dashboard_forbidden.png)

Need to create a user with admin binding to access metrics

---

As per manual some admins may give `kubernetes-dashboard` acoount `admin-cluster` role ([Source](https://github.com/kubernetes/dashboard/wiki/Access-control#admin-privileges)) and set `--enable-skip-flag` (set by default on versions <2.0).

It leads to auth bypass on dashboard, which is accessible from any pod by default

Needed configuration:

```diff
--- recommended.orig.yaml	2019-07-19 15:59:14.130001048 +0300
+++ recommended.yaml	2019-07-19 15:58:01.303334383 +0300
@@ -160,7 +160,7 @@
 roleRef:
   apiGroup: rbac.authorization.k8s.io
   kind: ClusterRole
-  name: kubernetes-dashboard
+  name: cluster-admin
 subjects:
   - kind: ServiceAccount
     name: kubernetes-dashboard
@@ -196,6 +196,7 @@
           args:
             - --auto-generate-certificates
             - --namespace=kubernetes-dashboard
+            - --enable-skip-login
             # Uncomment the following line to manually specify Kubernetes API server Host
             # If not specified, Dashboard will attempt to auto discover the API server and connect
             # to it. Uncomment only if the default does not work.

```

![Skip button](/imgs/dashboard_skip.png)

---

## Kube-dns

Provides simple service(and more) resolution by name

[Schema](https://github.com/kubernetes/dns/blob/master/docs/specification.md)

`<service>.<ns>.svc.<zone>. <ttl> IN A <cluster-ip>`

```console
$ dig kube-dns.kube-system.svc.cluster.local +short
10.96.0.10
```

However no ping and route:

```console
# ping 10.96.0.10
PING 10.96.0.10 (10.96.0.10): 56 data bytes
^C
--- 10.96.0.10 ping statistics ---
5 packets transmitted, 0 packets received, 100% packet loss
# ip r
default via 10.244.1.1 dev eth0
10.244.0.0/16 via 10.244.1.1 dev eth0
10.244.1.0/24 dev eth0 scope link  src 10.244.1.7
# ip r add 10.96.0.0/24 via 10.244.1.1
ip: RTNETLINK answers: Operation not permitted
# id
uid=0(root) gid=0(root) groups=0(root),1(bin),2(daemon),3(sys),4(adm),6(disk),10(wheel),11(floppy),20(dialout),26(tape),27(video)
```

### BUT!

```console
# dig kubernetes-dashboard.kubernetes-dashboard.svc.cluster.local +short
10.111.128.195
# ping 10.111.128.195
PING 10.111.128.195 (10.111.128.195): 56 data bytes
^C
--- 10.111.128.195 ping statistics ---
2 packets transmitted, 0 packets received, 100% packet loss
# curl -sk https://10.111.128.195
<!doctype html>
<html>

...
```

=> No default network policy for communication between namespaces!!!

---

## Helm

By default doesn't use TLS and X509 authorization

So, given access to some pod, we can run our malicious chart to take nodes

1. Download Helm
2. Get Tiller ip, thanks to kube-dns. `dig tiller-deploy.kube-system.svc.cluster.local`
3. `./helm --host tiller-deploy.kube-system.svc.cluster.local:44134 install pwnchart.tar.gz ...`

Demo:

<!-- <img src="./imgs/helm_pwn.svg"> -->

Mitigation:

If you don't want to use TLS remove Tiller service and path deployment to listen only on localhost

```console
$ kubectl -n kube-system delete service tiller-deploy
$ kubectl -n kube-system patch deployment tiller-deploy --patch '
spec:
  template:
    spec:
      containers:
        - name: tiller
          ports: []
          command: ["/tiller"]
          args: ["--listen=localhost:44134"]
'
```

Helm CLI uses port-forward via k8s api to reach tiller

Else enable TLS

More [here](https://engineering.bitnami.com/articles/helm-security.html)

Or wait for new version 3, which [removes Tiller at all](https://github.com/helm/community/blob/master/helm-v3/000-helm-v3.md).

---

## Making new ServiceAccounts

If you leak Helm or Dashboard account with `cluster-admin` role binding, attacker gets full access to everyhing
