# Thing you must do secure your cluster

- [Thing you must do secure your cluster](#thing-you-must-do-secure-your-cluster)
  - [1. Firewall your cluster](#1-firewall-your-cluster)
  - [2. Use RBAC](#2-use-rbac)
  - [3. Use network policies](#3-use-network-policies)
  - [4. Use pod security policies](#4-use-pod-security-policies)
  - [5. Follow container security best practices](#5-follow-container-security-best-practices)
  - [6. Manually recheck all hardenings](#6-manually-recheck-all-hardenings)
  - [7. Secure you app logic](#7-secure-you-app-logic)

## 1. Firewall your cluster

Do not expose control-plane _at all_. Use vpn or [bastion host](https://en.wikipedia.org/wiki/Bastion_host) to connect to your cluster.

If you need to use `NodePort`, use whitelist.

Disable Internet access for nodes that do not need it. (Although it can be done with network policies, you may forget about it)

Expose Ingress or load balancer instead of `NodePort`.

Even though all components has TLS authentication, a sudden vulnerability can cost you a cluster.

## 2. Use RBAC

Create new ServiceAccount for every component which requires querying API.

Limit allowed verbs and resources. Use principle of least privilege.

## 3. Use network policies

Isolate ingress and egress traffic to other namespaces **and** Internet . By default pod can communicate with other pod in **any** other namespace. Thus, pods can query other apps or 3rd party components (Dashboard, Tiller), which may be insecure and lead to token stealing.

## 4. Use pod security policies

No containers must be run as root or mount `/` as read-only.

This will harden attacker's life.

An example pod security policy:

```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted
  annotations:
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: "docker/default,runtime/default"
    apparmor.security.beta.kubernetes.io/allowedProfileNames: "runtime/default"
    seccomp.security.alpha.kubernetes.io/defaultProfileName: "runtime/default"
    apparmor.security.beta.kubernetes.io/defaultProfileName: "runtime/default"
spec:
  privileged: false
  # Required to prevent escalations to root.
  allowPrivilegeEscalation: false
  # This is redundant with non-root + disallow privilege escalation,
  # but we can provide it for defense in depth.
  requiredDropCapabilities:
    - ALL
  # Allow core volume types.
  volumes:
    - "configMap"
    - "emptyDir"
    - "projected"
    - "secret"
    - "downwardAPI"
    # Assume that persistentVolumes set up by the cluster admin are safe to use.
    - "persistentVolumeClaim"
  hostNetwork: false
  hostIPC: false
  hostPID: false
  runAsUser:
    # Require the container to run without root privileges.
    rule: "MustRunAsNonRoot"
  seLinux:
    # This policy assumes the nodes are using AppArmor rather than SELinux.
    rule: "RunAsAny"
  supplementalGroups:
    rule: "MustRunAs"
    ranges:
      # Forbid adding the root group.
      - min: 1
        max: 65535
  fsGroup:
    rule: "MustRunAs"
    ranges:
      # Forbid adding the root group.
      - min: 1
        max: 65535
  readOnlyRootFilesystem: false
```

## 5. Follow container security best practices

- Never run as root
- Update images
- Scan images on vulnerabilities
- Use minimal image like `alpine`, or even better [`distroless`](https://github.com/GoogleContainerTools/distroless)
- Never mount `docker.sock`, `kubelet`'s dirs, etc to container
- ...

More info [here](https://github.com/OWASP/CheatSheetSeries/blob/master/cheatsheets/Docker_Security_Cheat_Sheet.md)

## 6. Manually recheck all hardenings

- Pod security policies won't be applied without proper admission controller
- You won't get a warning if your CNI plugin doesn't support network policies

## 7. Secure you app logic

Nothing can help, if you let attacker exploit your app. 1-6 only harden the lateral movements
