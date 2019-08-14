# Kubernetes security

This repo is a collection of kubernetes security stuff and research.

The research was conducted during Summer of hack internship.

## Overview

- [Security notes](./NOTES.md)

  In-depth research about security of kubernetes features and misconfigurations. Source for all documents below

- [Security hardening and best practices](./HARDENING.md)

  A "must do"/best practices list of things to make attacker's life hard

- [Security flags checklist](./FLAGS.md)

  A checklist of flags to quickly test if your cluster has security features enabled.

- [Attacker's guide](./ATTACKER.md)

  A guide for attacker: what to do if he gets to pod/cluster.

  Also, some attacks included

- [Vulnerabilities](./VULN.md)

  Page with sources for security announces and previous vulnerabilities

## Tools

- [k8numerator](./k8numerate/README.md)

  Script for enumerating services in kubernetes cluster. Common services dictionary provided.

## Slides

- [Midterm](https://docs.google.com/presentation/d/1_D1fyl_DO0SGn3lh2lsEGMplRc9TegX8pEhVF9hnX_0/edit?usp=sharing)

## References

- [Kubernetes security audit](https://github.com/kubernetes/community/tree/master/wg-security-audit/findings)

  [Tracking issue](https://github.com/kubernetes/kubernetes/issues/81146)

- [Attacking Kubernetes](https://github.com/kubernetes/community/blob/master/wg-security-audit/findings/AtredisPartners_Attacking_Kubernetes-v1.0.pdf)
