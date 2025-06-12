FROM jenkins/jenkins:lts

USER root
RUN apt-get update && apt-get install -y curl && apt-get clean

COPY scripts/ /scripts/
RUN chmod +x /scripts/*.sh


USER jenkins

