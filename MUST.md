# Thing you must do secure your cluster

## 1. Firewall your cluster

Do not expose control-plane _at all_. Use vpn or [bastion host](https://en.wikipedia.org/wiki/Bastion_host) to connect to your cluster.

If you need to use `NodePort`, use whitelist.

Disable Internet access for nodes that do not need it. (Although it can be done with network policies, you may forget about it)

Expose Ingress or load balancer instead of `NodePort`.

## 2. Use RBAC

Create new ServiceAccount for every component which requires querying API.

Limit allowed verbs and resources. Use principle of least privillege.

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

## 5. Follow container security best practicies

- Never run as root
- Update images
- Scan images on vulnurabilities
- Use minimal image like `alpine`, or even better [`distroless`](https://github.com/GoogleContainerTools/distroless)
- Never mount `docker.sock`, `kubelet`'s dirs, etc to container
- ...

More info [here](https://github.com/OWASP/CheatSheetSeries/blob/master/cheatsheets/Docker_Security_Cheat_Sheet.md)

## 6. Secure you app logic

Nothing can help, if you let attacker exploit your app. 1-5 only harden the latheral movements
