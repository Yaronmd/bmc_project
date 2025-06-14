FROM jenkins/jenkins:lts

USER root

RUN apt-get update && \
    apt-get install -y curl docker.io && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY scripts/ /scripts/
RUN chmod +x /scripts/*.sh

# אל תחזיר ל-USER jenkins כדי להריץ כ-root
# USER jenkins
