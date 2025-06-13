#!/bin/bash

JENKINS_B_URL="${JENKINS_B_URL:-http://jenkins-b:8080}"
TARGET_JOB_NAME="${TARGET_JOB_NAME:-job-b}"
JENKINS_USER="${JENKINS_USER:-admin}"
JENKINS_API_TOKEN="${JENKINS_API_TOKEN:-your_real_token}"

echo "JENKINS_B_URL: $JENKINS_B_URL"
echo "JOB_NAME: $TARGET_JOB_NAME"
echo "JENKINS_USER: $JENKINS_USER"

echo "Triggering Jenkins B with crumb..."

CRUMB=$(curl -s --user "$JENKINS_USER:$JENKINS_API_TOKEN" \
  "$JENKINS_B_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)")

echo "Using crumb: $CRUMB"

QUEUE_URL=$(curl -s -X POST "$JENKINS_B_URL/job/$TARGET_JOB_NAME/build" \
  --user "$JENKINS_USER:$JENKINS_API_TOKEN" \
  -H "$CRUMB" -i | grep -i Location | awk '{print $2}' | tr -d '\r\n')

echo "Job queued at: $QUEUE_URL"

echo "$QUEUE_URL" > /tmp/jenkins_queue_url.txt