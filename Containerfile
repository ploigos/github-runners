FROM quay.io/redhat-github-actions/buildah-runner

ARG YQ_VERSION=3.4.1

USER root
RUN dnf install -y python3-pip maven skopeo
RUN pip install --upgrade git+https://github.com/ploigos/ploigos-step-runner.git@main

# Install YQ
RUN curl -L https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -o /usr/bin/yq &&\
    chmod +x /usr/bin/yq

USER $UID
