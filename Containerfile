FROM quay.io/redhat-github-actions/buildah-runner

USER root
RUN dnf install -y python3-pip maven skopeo
RUN pip install --upgrade git+https://github.com/ploigos/ploigos-step-runner.git@main

USER $UID
