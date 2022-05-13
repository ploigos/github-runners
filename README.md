# OpenShift GitHub Actions Runner image with Python

Based on the [OpenShift Github Actions Runners](https://github.com/redhat-actions/openshift-actions-runners)

## Building
```shell
buildah bud -t quay.io/dwinchell_redhat/python-runner .
podman push quay.io/dwinchell_redhat/python-runner 
```
