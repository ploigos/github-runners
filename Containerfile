FROM quay.io/redhat-github-actions/runner

USER root
RUN dnf install -y python3-pip maven buildah skopeo && \
    pip install --upgrade git+https://github.com/ploigos/ploigos-step-runner.git@main

# allow for subgid and subuid to be set at runtime for random UIDs
# needed to allow for buildah to call newgidmap and newuidmap
RUN chmod g+rw /etc/subgid /etc/subuid

USER $UID

# set up environment variables for use by podman/buildah/skopeo to be able to run as rootless
ENV _BUILDAH_STARTED_IN_USERNS="" BUILDAH_ISOLATION=chroot STORAGE_DRIVER="vfs"

