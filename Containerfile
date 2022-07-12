FROM registry.access.redhat.com/ubi8:latest

#Steps taken from: https://github.com/redhat-actions/openshift-actions-runners/blob/main/base/Containerfile

#ENV UID=1000
#ENV GID=0
#ENV USERNAME="runner"

USER root

RUN dnf -y update && \
    dnf -y module enable maven:3.6 python39:3.9 && \
    dnf -y --setopt=skip_missing_names_on_install=False install \
    curl git jq hostname procps findutils which openssl && \
    dnf install -y podman buildah fuse-overlayfs shadow-utils \
    python39 python39-pip maven skopeo --exclude container-selinux && \
    dnf -y reinstall shadow-utils && \
    dnf clean all

# Create our user and their home directory
#RUN useradd -m $USERNAME -u $UID
# This is to mimic the OpenShift behaviour of adding the dynamic user to group 0.
#RUN usermod -G 0 $USERNAME
#ENV HOME /home/${USERNAME}
#WORKDIR /home/${USERNAME}

# Override these when creating the container.
ENV GITHUB_PAT=""
ENV GITHUB_APP_ID=""
ENV GITHUB_APP_INSTALL_ID=""
ENV GITHUB_APP_PEM=""
ENV GITHUB_OWNER=""
ENV GITHUB_REPOSITORY=""
ENV RUNNER_WORKDIR=/opt/runner/
ENV RUNNER_GROUP=""
ENV RUNNER_LABELS=""
ENV EPHEMERAL=""

# Allow group 0 to modify these /etc/ files since on openshift, the dynamically-assigned user is always part of group 0.
# Also see ./uid.sh for the usage of these permissions.
RUN chmod g+w /etc/passwd && \
    touch /etc/sub{g,u}id && \
    chmod -v ug+rw /etc/sub{g,u}id

RUN mkdir $RUNNER_WORKDIR
COPY scripts/* $RUNNER_WORKDIR

# Set permissions so that we can allow the openshift-generated container user to access them.
# https://docs.openshift.com/container-platform/4.10/openshift_images/create-images.html#images-create-guide-openshift_create-images
RUN chgrp -R 0 $RUNNER_WORKDIR && \
    chmod -R g+rwX $RUNNER_WORKDIR

RUN $RUNNER_WORKDIR/get-runner-release.sh && \
    $RUNNER_WORKDIR/bin/installdependencies.sh

#Steps taken from https://github.com/redhat-actions/openshift-actions-runners/blob/main/buildah/Containerfile

ARG OC_VERSION=4.7.4
RUN curl -sSLf https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${OC_VERSION}/openshift-client-linux.tar.gz \
    | tar --exclude=README.md -xzvf - &&\
    mv kubectl oc /usr/local/bin/

ENV BUILDAH_ISOLATION=chroot
ENV BUILDAH_LAYERS=true

ADD https://raw.githubusercontent.com/containers/buildah/master/contrib/buildahimage/stable/containers.conf /etc/containers/

RUN chgrp -R 0 /etc/containers/ && \
    chmod -R a+r /etc/containers/ && \
    chmod -R g+w /etc/containers/

# Use VFS since fuse does not work
# https://github.com/containers/buildah/blob/master/vendor/github.com/containers/storage/storage.conf
#RUN mkdir -vp /home/${USERNAME}/.config/containers && \
RUN printf '[storage]\ndriver = "vfs"\n' > /etc/containers/storage.conf
#    chown -Rv ${USERNAME} /home/${USERNAME}/.config/

ARG YQ_VERSION=3.4.1
ARG ARGOCD_VERSION=v2.0.4

RUN pip3 install --upgrade git+https://github.com/ploigos/ploigos-step-runner.git@main

# Install yq and argocd
RUN curl -L https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -o /usr/bin/yq &&\
    chmod +x /usr/bin/yq &&\
    curl -L https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64 -o /usr/bin/argocd && \
    chmod 775 /usr/bin/argocd && chgrp 0 /usr/bin/argocd

USER 1001

ENTRYPOINT ./entrypoint.sh
