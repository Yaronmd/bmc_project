#!/bin/bash

echo "Triggering Jenkins B on $JENKINS_B_URL"
echo "Using user: $JENKINS_USER"

CRUMB=$(curl -s --user "$JENKINS_USER:$JENKINS_API_TOKEN" \
  "$JENKINS_B_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)")

if [ -z "$CRUMB" ]; then
    echo "Failed to obtain crumb! Check URL, credentials, or CSRF config."
    curl -v --user "$JENKINS_USER:$JENKINS_API_TOKEN" "$JENKINS_B_URL/crumbIssuer/api/xml"
    exit 1
fi

echo "Using crumb: $CRUMB"

QUEUE_URL=$(curl -s -X POST "$JENKINS_B_URL/job/$TARGET_JOB_NAME/build" \
  --user "$JENKINS_USER:$JENKINS_API_TOKEN" \
  -H "$CRUMB" -i | grep -i Location | awk '{print $2}' | tr -d '\r\n')

echo "Job queued at: $QUEUE_URL"

if [ -z "$QUEUE_URL" ]; then
    echo "Failed to queue job!"
    exit 1
fi

echo "$QUEUE_URL" > /tmp/jenkins_queue_url.txt
