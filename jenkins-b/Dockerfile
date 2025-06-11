FROM jenkins/jenkins:lts

USER root

RUN apt-get update && \
    apt-get install -y python3 && \
    apt-get clean

USER jenkins
