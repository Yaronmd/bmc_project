FROM jenkins/jenkins:lts

USER root
RUN apt-get update && apt-get install -y curl && apt-get clean
RUN chmod +x /scripts/*.sh


USER jenkins

