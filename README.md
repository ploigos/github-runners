# Ploigos OpenShift GitHub Actions Runner Images

Based on the [OpenShift Github Actions Runners](https://github.com/redhat-actions/openshift-actions-runners)

This repository has a Github Actions workflow that automatically builds and publishes changes to the image.
## Building Image Manually
```shell
buildah bud -t quay.io/dwinchell_redhat/python-runner .
podman push quay.io/dwinchell_redhat/python-runner 
```

## Contributing
When contributing to this repository, you **MUST** use the `feature/*` branch naming convention in order for the Github 
Actions workflow to be triggered to build and push to a new image.