# k8numerate

Enumerate kubernetes services

## WARNING

> There's a better way to discover all services with **one** DNS query. Use the tool only if you can't query SRV record on `*.*.svc.cluster.local`
>
> Check it out [here](../NOTES.md) Kube-dns -> services

## Usage

```
enumerate.sh [-h|--help] [-v|--verbose] dictionary...

k8numerate - enumerate kubernetes services

Usage:
  enumerate.sh [options] services.txt

Options:
  -v --verbose  verbose output
  -h --help show this screen
```

## Prerequisites

1. Generate services dictionary

Run `generate.py services.json svc.txt`

2. Run `enumerate.sh svc.txt`

## Service format

Array of:

```json
{
  "description": "Service description",
  "name": ["service-name"],
  "namespace": ["service-namespace"]
}
```
