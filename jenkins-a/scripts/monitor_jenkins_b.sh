#!/bin/bash

if [[ -z "$JENKINS_B_URL" || -z "$TARGET_JOB_NAME" || -z "$JENKINS_USER" || -z "$JENKINS_API_TOKEN" ]]; then
  echo "Missing required environment variables!"
  exit 1
fi

if [ ! -f /tmp/jenkins_queue_url.txt ]; then
  echo "/tmp/jenkins_queue_url.txt not found. Trigger script may have failed."
  exit 1
fi

QUEUE_URL=$(cat /tmp/jenkins_queue_url.txt)

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

echo "Waiting for build to complete..."
for i in {1..30}; do
    BUILD_STATUS=$(curl -s --user "$JENKINS_USER:$JENKINS_API_TOKEN" \
        "$JENKINS_B_URL/job/$TARGET_JOB_NAME/$BUILD_NUMBER/api/json" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)

    if [[ "$BUILD_STATUS" != "null" && -n "$BUILD_STATUS" ]]; then
        echo "Build finished with status: $BUILD_STATUS"
        break
    fi
    sleep 2
done

if [[ "$BUILD_STATUS" != "SUCCESS" ]]; then
    echo "Build failed or did not succeed."
    exit 1
else
    echo "Build succeeded."
fi

echo "Fetching console log..."
curl --user "$JENKINS_USER:$JENKINS_API_TOKEN" \
  "$JENKINS_B_URL/job/$TARGET_JOB_NAME/$BUILD_NUMBER/consoleText"
