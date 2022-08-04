# Ploigos OpenShift GitHub Actions Runner Images

Based on the [OpenShift Github Actions Runners](https://github.com/redhat-actions/openshift-actions-runners)

This repository has a Github Actions workflow that automatically builds and publishes changes to the image.
## Building Image Manually
```shell
buildah bud -t quay.io/ploigos/ploigos-github-runner .
podman push quay.io/ploigos/ploigos-github-runner
```

## Contributing
When contributing to this repository, you **MUST** use the `feature/*` branch naming convention in order for the Github 
Actions workflow to be triggered to build and push to a new image.

## Stuff pulled from the interwebs:

| File/Purpose              | URL                                                                                                          |
|---------------------------|--------------------------------------------------------------------------------------------------------------|
| GitHub Runner Release API | https://api.github.com/repos/actions/runner/releases/latest                                                  |
 | OpenShift CLI             | https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${OC_VERSION}/openshift-client-linux.tar.gz |

