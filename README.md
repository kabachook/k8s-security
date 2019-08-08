# k8s-security

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

## ENV

K8s v1.15.0

IPs:

- Router `172.16.0.1`
- Master/control-plane node `172.16.0.2` - `ubuntu0`
- Worker node `172.16.0.3` - `ubuntu1`

Settings:

- CRI - Docker 18.09.7
- CNI - Flannel 0.11.0

External components:

- Kubernetes dashboard 2.0.0-beta2
- Helm & Tiller 2.14.2

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
| 10251 | kube-scheduler          | k8s pod scheduler, exposes some metrics in prometheus format     | `curl http://ip:10251/metrics`                    |
| 10252 | kube-controller-manager | k8s control loop to reach desired cluster state, exposes metrics | `curl http://ip:10252/metrics`                    |
| 10256 | kube-proxy              | k8s proxy for port forwarding                                    | -                                                 |

**Nodes**

| Port  | Component  | Description                   | How to query                                      |
| ----- | ---------- | ----------------------------- | ------------------------------------------------- |
| 10250 | kubelet    | k8s node agent                | `curl https://ip:10250/{metrics,stats,logs,spec}` |
| 10256 | kube-proxy | k8s proxy for port forwarding | -                                                 |

---

## API example

_Get all pods_:

```console
$ curl -s --cacert ca.pem --cert client.pem --key key.pem https://172.16.0.2:6443/api/v1/pods | jq '.items[].metadata.name'
"nginx"
"coredns-5c98db65d4-7d6mg"
"coredns-5c98db65d4-hlpxx"
"etcd-ubuntu0"
"kube-apiserver-ubuntu0"
"kube-controller-manager-ubuntu0"
"kube-flannel-ds-amd64-cpvd8"
"kube-flannel-ds-amd64-xxv5m"
"kube-proxy-cftbs"
"kube-proxy-xdsmx"
"kube-scheduler-ubuntu0"
"tiller-deploy-56c686464b-t95nf"
"dashboard-metrics-scraper-6ff95d79d8-2s926"
"kubernetes-dashboard-68d4968d4d-vmg6d"
"grafana-75c5895769-8g58b"
"prometheus-alertmanager-7f956dff49-29dng"
"prometheus-kube-state-metrics-859fb585d5-pvtqz"
"prometheus-node-exporter-cl4fc"
"prometheus-pushgateway-55d9fbd64f-wz2lc"
"prometheus-server-5f7cc875bf-qgzhp"
```

_Get all secrets_:

```console
$ curl -s --cacert ca.pem --cert client.pem --key key.pem https://172.16.0.2:6443/api/v1/secrets | jq '.items[4]' # remove pipe to get all secrets
{
  "metadata": {
    "name": "admin-user-token-xshtw",
    "namespace": "kube-system",
    "selfLink": "/api/v1/namespaces/kube-system/secrets/admin-user-token-xshtw",
    "uid": "5be439d1-1ad3-478e-9388-fdfada0c06b3",
    "resourceVersion": "319938",
    "creationTimestamp": "2019-07-19T10:43:11Z",
    "annotations": {
      "kubernetes.io/service-account.name": "admin-user",
      "kubernetes.io/service-account.uid": "ed05d99b-ddd1-43e5-800c-fd4de957a71f"
    }
  },
  "data": {
    "ca.crt": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RENDQWJDZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRFNU1EY3hOakUxTXpFeU5Gb1hEVEk1TURjeE16RTFNekV5TkZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBS2Z4CklYUVQ0dFU3eTNqQ0hiN0pKdUYwbGVteTI1NGNlQ3RxZXE5TE9PdjhReVVyS29pb2NKdVE3TFBKZ3VObWNHQWIKREgzeWszM2NVSlc0MnliUnZOc1l3bUZkOXhJL0cvSEdUUCttQ3BtUUZTREc1cHAzTXVrd0IwclR3SEMxVWpDaQpRaTZCVUszNmgxQlRxRHV5TzNiZ1ZGdllXWU9icEdPZ0RGWUduY0tsMWVLZTNJQWkyWHMrdG9FVURESGJWWWQ1Cjhzc0RBdjdSd3JpdTk0MFpxN2NJamVVUnhyaG1vTjBpKzAwYXdtNXU0cDhJbk1TQzFRdjRUZkRjWFJ3cWlQTnQKZnE5Z29NRzVCbVRnWUg2VmRXTUhLeUJtYmJFcWZqSHFDYUNteUVIOW9JU2Qrd01RUUtWR29UZUFMajdHZVE4NwpQZXR6emErR0tnQmhQeE1GSzI4Q0F3RUFBYU1qTUNFd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFJVk1aQnd1Z3c3VitDYUhmRE05WEgwS2dFMGUKdnN5Ymd1R21XMCsxWG9wSkRwdUl3TGtiOE5FSGtjeUp4YUc5OEZPZ1FveGpvQldLVUxWL3JLLzgyWGl1YjVRVQorZ1hVTmEwQVJLZXZtcUZGMURRRmlIVkRYWFRKRlBRZEkvdk5XbDl5UDhJTmF3dW5iRmJ2MitmVFlYRzZ5VStaCjB1dVlWT25pZ2xEL2E0QzJFN0FKQTNGRGxJS0xiNjJ0eWROb0ZKdFR3eTFmZmxzUVNXVkIvYWI2K0ZHMXZkTDgKVVBoVWJuWVZmYVRjL2FCQ0JhYWVkVHByWUtYOEMwNm1uWlFqZXFRNWRwTHprL2RVdU5SL2pPSDBwVjhCOWZOeQo1SURCR0wxbnBFdEl3czgxLzlGdy9scTBPVmVILzNtSXE4MXQ2ZkthY0EwY3VBYjQ0QndiWWRQajBIQT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=",
    "namespace": "a3ViZS1zeXN0ZW0=",
    "token": "ZXlKaGJHY2lPaUpTVXpJMU5pSXNJbXRwWkNJNklpSjkuZXlKcGMzTWlPaUpyZFdKbGNtNWxkR1Z6TDNObGNuWnBZMlZoWTJOdmRXNTBJaXdpYTNWaVpYSnVaWFJsY3k1cGJ5OXpaWEoyYVdObFlXTmpiM1Z1ZEM5dVlXMWxjM0JoWTJVaU9pSnJkV0psTFhONWMzUmxiU0lzSW10MVltVnlibVYwWlhNdWFXOHZjMlZ5ZG1salpXRmpZMjkxYm5RdmMyVmpjbVYwTG01aGJXVWlPaUpoWkcxcGJpMTFjMlZ5TFhSdmEyVnVMWGh6YUhSM0lpd2lhM1ZpWlhKdVpYUmxjeTVwYnk5elpYSjJhV05sWVdOamIzVnVkQzl6WlhKMmFXTmxMV0ZqWTI5MWJuUXVibUZ0WlNJNkltRmtiV2x1TFhWelpYSWlMQ0pyZFdKbGNtNWxkR1Z6TG1sdkwzTmxjblpwWTJWaFkyTnZkVzUwTDNObGNuWnBZMlV0WVdOamIzVnVkQzUxYVdRaU9pSmxaREExWkRrNVlpMWtaR1F4TFRRelpUVXRPREF3WXkxbVpEUmtaVGsxTjJFM01XWWlMQ0p6ZFdJaU9pSnplWE4wWlcwNmMyVnlkbWxqWldGalkyOTFiblE2YTNWaVpTMXplWE4wWlcwNllXUnRhVzR0ZFhObGNpSjkuaS1kTS1kUW4ybjkwNVVDNVlSZ3h0aDBDR0VNM1QySEZ3ME01X3E0a0loSXVKR1YwV290b04yMlFWVXU1LW5jQ0c1ejZwbmxSS1g2R1R1bXdNS1Awdm44M3RDU1NhM0xLVkRVWnA3el8xM3BoN2RuOUxERm1SNVJ1ald1dXFXWU05d0JMTU1lQWlNaDFWLVpzT09GM2llUS1seS13WnNmbkRLa0N5MVlrdE03OVJac2FOQ3ZTeUVuVFJLendsRDU2RWN5cGw5QVc2U0dJcWJHMzcyWGQtNVhvbUc3R2JHLXBWMll6ZnJOdlJWNnlRVENxVTNrdllYeTZpSEZXeDA5bnk1RU54YlRhbVRLSk9jTmp6X0ZidGdjanYtM1h0UzJLMUJ6YUd0NVZPWXlpN243NE5mZXFwdHJkcW1oOHo5Z2EtTWJfc2Q0SHY2VWN6bE5DdTFyNVhn"
  },
  "type": "kubernetes.io/service-account-token"
}
```

_Execute commands inside pod's container:_

```console
$ wscat --ca ca.pem --cert client.pem --key key.pem --connect "https://172.16.0.2:6443/api/v1/namespaces/default/pods/nginx/exec?command=id&container=nginx&stderr=true&stdout=true"
connected (press CTRL+C to quit)
<
< uid=0(root) gid=0(root) groups=0(root)

disconnected (code: 1000)
```

**Tip**

Use `kubectl -v=7` to get curl equivalent of your qeury

---

- kube-scheduler api on `:10251`

  ```console
  root@ubuntu1:~# curl -sk http://172.16.0.2:10251/metrics
  # Very long output here...
  # TYPE kubernetes_build_info gauge
  kubernetes_build_info{buildDate="2019-06-19T16:32:14Z",compiler="gc",gitCommit="e8462b5b5dc2584fdcd18e6bcfe9f1e4d970a529",gitTreeState="clean",gitVersion="v1.15.0",goVersion="go1.12.5",major="1",minor="15",platform="linux/amd64"} 1
  ```

  Same for `10252` port

  Not very useful, but get k8s version always. Maybe some other stuff on previous versions

---

Compared to previous versions of k8s:

- All `kubelet`'s are using auth now
- Can't query anything with default ServiceAccount token in pods

=> Pretty secure(?)

- RBAC enabled by default with webhook mode
- Default ServiceToken on pods has no power
- Metrics do not expose pods ips and metadata, only master

---

However

- No auth logging set up
- No pods interconnection policies
- No run as non-root container enforcement
- No egress traffic restriction to `kube-system` namespace
- ServiceAccount tokens still present on pods (`automountServiceAccountToken:false`)
- No automatic certificate rotation

---

## Config files

For both master and node

- `/etc/kubernetes/*.conf` - credentials for apiserver of components(including cluster admin config!)
- `/etc/kubernetes/manifests/*.yaml` - cluster components(etcd, apiserver, control-manager, scheduler) configs
- `/etc/kubernetes/pki/**/*` - certs and keys for all components
- `/var/lib/kubelet/**/*` - kubelet files

Everything should be readable only for root and k8s admin user(if present)
Exception: all `*.crt` files can be public

By default only readable for root

---

## Secret files

Must be readable only for root

### Master

- `/etc/kubernetes/admin.conf` - cluster admin credentials
- `/etc/kubernetes/{kubelet,control-manager,scheduler}.conf` - components credentials
- `/etc/kubernetes/pki` - PKI folder, contains keys and CA, keys for apiserver and other components
- `/var/lib/kubelet/config.yaml` - kubelet config (includes CA path)

### Nodes

- `/var/lib/kubelet/config.yaml` - kubelet config (includes CA path)

### Pods

- `/var/run/secrets/kubernetes.io/serviceaccount/*` - default ServiceAccount token, and apiserver CA cert. Useless by default, if not given additional privileges

---

## Kubernetes dashboard

No access by default service token => Good

![Dashboard with default token](/imgs/dashboard_forbidden.png)

Need to create a user with admin binding to access metrics

---

As per manual some admins may give `kubernetes-dashboard` account `admin-cluster` role ([Source](https://github.com/kubernetes/dashboard/wiki/Access-control#admin-privileges)) and set `--enable-skip-flag` (set by default on versions <2.0).

It leads to auth bypass on dashboard, which is accessible from any pod by default

Needed configuration:

```diff
--- recommended.orig.yaml
+++ recommended.yaml
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

## Helm

By default doesn't use TLS and X509 authorization

So, given access to some pod, we can run our malicious chart to take nodes

1. Download Helm
2. Get Tiller ip, thanks to kube-dns. `dig tiller-deploy.kube-system.svc.cluster.local`
3. `./helm --host tiller-deploy.kube-system.svc.cluster.local:44134 install pwnchart.tar.gz ...`

Demo [here](./imgs/helm_pwn.svg)

Mitigation:

If you don't want to use TLS remove Tiller service and patch deployment to listen only on localhost

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

## ETCD

`etcd` is a key-value storage for kubernetes needs. It contains all secrets and other info.

It is a common attack vector for taking down kubernetes cluster.

At least since version `1.15` etcd is secured by default:

- Ports listening only on `127.0.0.1` and your external interface
- Uses peer TLS authentication

If your cluster is _directly exposed_ to the Internet (your external interface has public ip), you **SHOULD** close ports and change config to listen only on `127.0.0.1` and your internal ip accessible by `kube-apiserver`. Otherwise it may lead to cluster takedown, even though it has TLS authn.

---

## ServiceAccounts

ServiceAccount is a "user account for pod". It allows to do all things that regular user account can do.

Frequently used in kubernetes related apps like Dashboard or Helm.

Hence, ServiceAccount security is important too!

### Roles and RoleBindings

```
ServiceAccount <----RoleBinding----> Role
```

ServiceAccount gets its permissions via RoleBinding, which is a connection between role and account.

In many apps it is required to create ServiceAccount with `cluster-admin` role binding, to work properly. Since `cluster-admin` role allows you to do anything in cluster, it leads to high risk of ServiceAccount token steal.

For example, if you leak Helm or Dashboard account with `cluster-admin` role binding, attacker gets **full access to your cluster**

_Mitigation:_

Use namespaces. Never give an account a `cluster-admin` role.

If you need admin privileges for your app(e.g. Tiller), create a new namespaced ServiceAccount.

Also use principle of least when creating new ServiceAccounts

---

## Network policies

> A network policy is a specification of how groups of pods are allowed to communicate with each other and other network endpoints.

! Network policies require CNI support.

Many attack vectors can be eliminated by setting up network policies. Denying egress/ingress traffic from application namespace to Tiller and Dashboards protects from the attacks described above.

Besides many developers do not imply any auth in their microservices/apps. Attacker would not need to elevate privileges or capture nodes, if they could connect to your services without auth.

_Limit egress traffic to namespace and whitelist kube-dns:_

```console
$ kubectl label ns default namespace=default
$ kubectl label ns kube-system namespace=kube-system
```

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default.egress_and_dns
  namespace: default
spec:
  podSelector: {}
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              namespace: kube-system
          podSelector:
            matchLabels:
              k8s-app: kube-dns
      ports:
        - protocol: UDP
          port: 53
    - to:
        - namespaceSelector:
            matchLabels:
              namespace: default
  policyTypes:
    - Egress
```

[Useful recipes](https://github.com/ahmetb/kubernetes-network-policy-recipes)

[Good introduction](https://medium.com/@reuvenharrison/an-introduction-to-kubernetes-network-policies-for-security-people-ba92dd4c809d)

---

## Pod security policies

> A Pod Security Policy is a cluster-level resource that controls security sensitive aspects of the pod specification. The PodSecurityPolicy objects define a set of conditions that a pod must run with in order to be accepted into the system, as well as defaults for the related fields.

Useful conditions:

- `privileged: false` - don't allow privileged pods
- `allowPrivilegeEscalation: false` - prevent privilege escalation
- ```yaml
  runAsUser:
    rule: "MustRunAsNonRoot"
  ```

  Require the container to run without root privileges

- ```yaml
  hostNetwork: false
  hostIPC: false
  hostPID: false
  ```

  Disallow host namespaces usage

Read more conditions [here](https://kubernetes.io/docs/concepts/policy/pod-security-policy/)

Also, you can enable SELinux, AppArmor, Seccomp

---

## Container images

Rule of thumb:

> Less apps/programs - less vulnerabilities

[Reference](https://snyk.io/blog/top-ten-most-popular-docker-images-each-contain-at-least-30-vulnerabilities/)

Always use `alpine` for your apps, add only needed packages.

[Distroless](https://github.com/GoogleContainerTools/distroless) provides even better security, containing only the runtime (no bash, sh, etc)
