#!/bin/bash
echo "🧼 Cleaning up old Jenkins A volume..."
docker volume rm -f bmc_project_jenkins-a-data 2>/dev/null


echo "🚀 Starting Jenkins A & B with Docker Compose..."
docker compose up -d

echo -e "\n⏳ Waiting for Jenkins A & B to initialize..."

wait_for_password_file() {
  CONTAINER=$1
  FILE=$2
  NAME=$3

  echo -n "🔍 Checking $NAME"
  for i in {1..60}; do
    docker exec "$CONTAINER" test -f "$FILE" && break
    echo -n "."
    sleep 1
  done
  echo
}

wait_for_password_file jenkins-a /var/jenkins_home/secrets/initialAdminPassword "Jenkins A"
wait_for_password_file jenkins-b /var/jenkins_home/secrets/initialAdminPassword "Jenkins B"

echo -e "\nFetching initial admin passwords:\n"

echo "Jenkins A password:"
docker exec jenkins-a cat /var/jenkins_home/secrets/initialAdminPassword || echo "Jenkins A not ready"

echo -e "\nJenkins B password:"
docker exec jenkins-b cat /var/jenkins_home/secrets/initialAdminPassword || echo "Jenkins B not ready"
