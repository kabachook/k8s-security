# k8s-security

## How to know you are in docker container

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

## How to know if you are in kubernetes pod

- docker signs
- hostname like `<app-name>-<random hex>-<shorter random hex>`

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
