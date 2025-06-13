#!/bin/bash

if [[ -z "$JENKINS_B_URL" || -z "$TARGET_JOB_NAME" || -z "$JENKINS_USER" || -z "$JENKINS_API_TOKEN" ]]; then
  echo "Missing required environment variables!"
  exit 1
fi

echo "JENKINS_B_URL: $JENKINS_B_URL"
echo "JOB_NAME: $TARGET_JOB_NAME"
echo "JENKINS_USER: $JENKINS_USER"

echo "Triggering Jenkins B with crumb..."

CRUMB=$(curl -s --user "$JENKINS_USER:$JENKINS_API_TOKEN" \
  "$JENKINS_B_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)")

if [[ -z "$CRUMB" ]]; then
  echo "Failed to get crumb"
  exit 1
fi

echo "Using crumb: $CRUMB"

QUEUE_URL=$(curl -s -X POST "$JENKINS_B_URL/job/$TARGET_JOB_NAME/build" \
  --user "$JENKINS_USER:$JENKINS_API_TOKEN" \
  -H "$CRUMB" -i | grep -i Location | awk '{print $2}' | tr -d '\r\n')

if [[ -z "$QUEUE_URL" ]]; then
  echo "Failed to trigger Jenkins B job"
  exit 1
fi

echo "Job queued at: $QUEUE_URL"
echo "$QUEUE_URL" > /tmp/jenkins_queue_url.txt
