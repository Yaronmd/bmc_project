#!/bin/bash

set -e  # עצור אם יש שגיאה

echo "🔧 Building and running test-ls container..."
docker build -f Dockerfile.test_ls -t test-ls .
docker run --rm test-ls

echo ""
echo "Building and running test-trigger-jenkins container..."
docker build -f Dockerfile.test_trigger_jenkins -t test-trigger-jenkins .
docker run --rm --env-file=jenkins-a/scripts/.env test-trigger-jenkins

echo ""
echo "All tests completed successfully."
