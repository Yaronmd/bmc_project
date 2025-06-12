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

echo "Waiting for job to start..."
for i in {1..30}; do
    BUILD_INFO=$(curl -s --user "$JENKINS_USER:$JENKINS_API_TOKEN" "${QUEUE_URL}api/json")
    BUILD_NUMBER=$(echo "$BUILD_INFO" | grep -o '"number":[0-9]*' | grep -o '[0-9]*')
    if [ -n "$BUILD_NUMBER" ]; then
        echo "Build started with number: $BUILD_NUMBER"
        break
    fi
    sleep 2
done

if [ -z "$BUILD_NUMBER" ]; then
    echo "Build did not start in time."
    exit 1
fi

echo "Fetching console log..."
curl --user "$JENKINS_USER:$JENKINS_API_TOKEN" \
  "$JENKINS_B_URL/job/$TARGET_JOB_NAME/$BUILD_NUMBER/consoleText"
