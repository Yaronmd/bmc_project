#!/bin/bash

if [[ -z "$JENKINS_B_URL" || -z "$TARGET_JOB_NAME" || -z "$JENKINS_USER" || -z "$JENKINS_API_TOKEN" ]]; then
  echo "Missing required environment variables!"
  exit 1
fi

echo "Triggering Jenkins B on $JENKINS_B_URL"
echo "Using user: $JENKINS_USER"

CRUMB=$(curl -s --user "$JENKINS_USER:$JENKINS_API_TOKEN" \
  "$JENKINS_B_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)")

if [ -z "$CRUMB" ]; then
  echo "Failed to obtain crumb!"
  exit 1
fi

echo "Using crumb: $CRUMB"

QUEUE_URL=$(curl -s -X POST "$JENKINS_B_URL/job/$TARGET_JOB_NAME/build" \
  --user "$JENKINS_USER:$JENKINS_API_TOKEN" \
  -H "$CRUMB" -i | grep -i Location | awk '{print $2}' | tr -d '\r\n')

if [ -z "$QUEUE_URL" ]; then
  echo "Failed to trigger Jenkins B job or no queue URL returned!"
  exit 1
fi

echo "Job queued at: $QUEUE_URL"
echo "$QUEUE_URL" > /tmp/jenkins_queue_url.txt
