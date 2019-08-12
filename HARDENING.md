# Thing you must do secure your cluster

## Firewall your cluster

Do not expose control-plane _at all_. You must not run your apps on master node. Use vpn or [bastion host](https://en.wikipedia.org/wiki/Bastion_host) to connect to your cluster.

If you need to use `NodePort`, use whitelist.

Disable Internet access for nodes that do not need it. (Although it can be done with network policies, you may forget about it)

Expose Ingress or load balancer instead of `NodePort`.

Even though all components has TLS authentication, a sudden vulnerability can cost you a cluster.

### etcd

`etcd` **SHOULD NOT** be available for anything other that `apiserver`

## Use RBAC

Create new ServiceAccount for every component which requires querying API.

Limit allowed verbs and resources. Use principle of least privilege.

## Use network policies

Isolate ingress and egress traffic to other namespaces **and** Internet . By default pod can communicate with other pod in **any** other namespace. Thus, pods can query other apps or 3rd party components (Dashboard, Tiller), which may be insecure and lead to token stealing.

## Use pod security policies

No containers must be run as root and mount `/` as read-only if possible.

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

## Follow container security best practices

- Never run as root
- Update images
- Scan images on vulnerabilities
- Use minimal image like `alpine`, or even better [`distroless`](https://github.com/GoogleContainerTools/distroless)
- Never mount `docker.sock`, `kubelet`'s dirs, etc to container
- ...

More info [here](https://github.com/OWASP/CheatSheetSeries/blob/master/cheatsheets/Docker_Security_Cheat_Sheet.md)

## Protect against external attacks

If you are not sure about the security of the underlying network of cloud infrastructure, or your nodes communicate via the Internet(:scream:).

Possible attacks are:

- Man-in-the-middle attack (ARP spoofing, DHCP/DHCPv6 spoofing, etc)
- Somebody stoles your disks

Recommendations:

- Encrypt network communications via CNI plugin.

For example: use [Linkerd](https://linkerd.io/) which encrypts _by default_ with no pain

- Encrypt secrets

[k8s docs article](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/)

Do not forget:

> Storing the raw encryption key in the EncryptionConfig only moderately improves your security posture, compared to no encryption. Please use kms provider for additional security.

Another solution can be [HashiCorp's Vault](https://itnext.io/effective-secrets-with-vault-and-kubernetes-9af5f5c04d06), if you want to distribute secrets to your apps

- Enable TLS/mTLS everywhere in the cluster
- Apply encryption to your apps/databases to protect your data

## Set up audit logs

Send authn/authz logs to log collector and analyze them.

Useful fields in [notes](./README.md)

## Manually recheck all hardenings

- Pod security policies won't be applied without proper admission controller
- You won't get a warning if your CNI plugin doesn't support network policies

## Secure you app logic

Nothing can help, if you let attacker exploit your app. 1-6 only harden the lateral movements
