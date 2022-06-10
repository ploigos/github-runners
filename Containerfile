FROM quay.io/aagreen/buildah-runner:ubi8

ARG YQ_VERSION=3.4.1
ARG ARGOCD_VERSION=v2.0.4

USER root
RUN dnf install -y python3-pip maven skopeo
RUN pip install --upgrade git+https://github.com/ploigos/ploigos-step-runner.git@main

# Install yq and argocd
RUN curl -L https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -o /usr/bin/yq &&\
    chmod +x /usr/bin/yq &&\
    curl -L https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64 -o /usr/bin/argocd && \
    chmod 775 /usr/bin/argocd && chown 1001:0 /usr/bin/argocd

USER $UID
