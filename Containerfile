FROM registry.access.redhat.com/ubi8:latest

#Steps taken from: https://github.com/redhat-actions/openshift-actions-runners/blob/main/base/Containerfile

USER root

#Install necessary packages
RUN dnf -y update && \
    dnf -y module enable maven:3.6 python39:3.9 dotnet-sdk-6.0 && \
    dnf -y --setopt=skip_missing_names_on_install=False install \
    curl git jq hostname procps findutils which openssl \
    podman buildah fuse-overlayfs shadow-utils python39 \
    python39-pip maven skopeo openscap-scanner --exclude container-selinux && \
    dnf -y reinstall shadow-utils && \
    dnf clean all

ENV HOME /opt/runner
WORKDIR ${HOME}

# Override these when creating the container.
ENV GITHUB_PAT=""
ENV GITHUB_APP_ID=""
ENV GITHUB_APP_INSTALL_ID=""
ENV GITHUB_APP_PEM=""
ENV GITHUB_OWNER=""
ENV GITHUB_REPOSITORY=""
ENV RUNNER_WORKDIR=${HOME}/_work
ENV RUNNER_GROUP=""
ENV RUNNER_LABELS=""
ENV EPHEMERAL=""

# Allow group 0 to modify these /etc/ files since on openshift, the dynamically-assigned user is always part of group 0.
# Also see ./uid.sh for the usage of these permissions.
RUN chmod g+w /etc/passwd && \
    touch /etc/sub{g,u}id && \
    chmod -v ug+rw /etc/sub{g,u}id

COPY scripts/* ${HOME}/

RUN ${HOME}/get-runner-release.sh && \
    ${HOME}/bin/installdependencies.sh

# Set permissions so that we can allow the openshift-generated container user to access them.
# https://docs.openshift.com/container-platform/4.10/openshift_images/create-images.html#images-create-guide-openshift_create-images
RUN chgrp -R 0 ${HOME} && \
    chmod -R g+rwX ${HOME}

#Steps taken from https://github.com/redhat-actions/openshift-actions-runners/blob/main/buildah/Containerfile
ARG OC_VERSION=4.7.4
RUN curl -sSLf https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${OC_VERSION}/openshift-client-linux.tar.gz \
    | tar --exclude=README.md -xzvf - &&\
    mv kubectl oc /usr/local/bin/

# Set VFS in ENV variable since fuse does not work
# https://github.com/containers/buildah/blob/master/vendor/github.com/containers/storage/storage.conf
ENV _BUILDAH_STARTED_IN_USERNS="" BUILDAH_ISOLATION=chroot STORAGE_DRIVER="vfs"
ENV BUILDAH_LAYERS=true

ADD etc/containers/containers.conf /etc/containers/

RUN chgrp -R 0 /etc/containers/ && \
    chmod -R a+r /etc/containers/ && \
    chmod -R g+w /etc/containers/

ARG YQ_VERSION=3.4.1
ARG ARGOCD_VERSION=v2.0.4

RUN pip3 install --upgrade git+https://github.com/ploigos/ploigos-step-runner.git@main

# Install yq, argocd and config-lint
RUN curl -L https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -o /usr/bin/yq &&\
    chmod +x /usr/bin/yq && \
    curl -L https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64 -o /usr/bin/argocd && \
    chmod 775 /usr/bin/argocd && chgrp 0 /usr/bin/argocd && \
    curl -L https://github.com/stelligent/config-lint/releases/latest/download/config-lint_Linux_x86_64.tar.gz --output config-lint.tar.gz && \
    tar xzf ./config-lint.tar.gz -C /usr/bin/ && rm ./config-lint.tar.gz && \
    chmod 775 /usr/bin/config-lint && chgrp 0 /usr/bin/config-lint

USER 1001

ENTRYPOINT ./entrypoint.sh
