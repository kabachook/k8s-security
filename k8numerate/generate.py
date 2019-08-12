"""
Script generates domain dictionary for enumerate.sh
"""
import sys
from json import loads
from itertools import product

CLUSTER_NAME = "cluster.local"

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("No services file provided")
        print("Usage: {} services.json out.txt".format(sys.argv[0]))
        exit(1)

    with open(sys.argv[1], "r") as services_raw:
        services = loads(services_raw.read())

    with open(sys.argv[2], "w") as out:
        for service in services:
            for svc_name, namespace in product(service["name"], service["namespace"]):
                out.write("{}.{}.svc.{}\n".format(
                    svc_name, namespace, CLUSTER_NAME))
