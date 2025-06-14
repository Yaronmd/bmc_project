FROM jenkins/jenkins:lts

USER root

RUN apt-get update && \
    apt-get install -y curl docker.io && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY scripts/ /scripts/

COPY config/requirements.txt .
COPY jenkins-a/tests/ .
COPY jenkins-a/scripts ./scripts

RUN chmod +x /scripts/*.sh

