FROM quay.io/redhat-github-actions/runner

USER root
RUN dnf search python3

USER $UID
