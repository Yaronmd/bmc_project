#!/bin/bash
set -e

cd "$(dirname "$0")/.."  # זז לשורש הפרויקט מהתיקייה שבה הסקריפט יושב

echo "🔧 Building and running test-ls container..."
docker build -f docker/Dockerfile.test_ls -t test-ls .
docker run --rm test-ls

echo ""
echo "Building and running test-trigger-jenkins container..."
docker build -f docker/Dockerfile.test_trigger_jenkins -t test-trigger-jenkins .
docker run --rm --env-file=jenkins-a/scripts/.env test-trigger-jenkins
