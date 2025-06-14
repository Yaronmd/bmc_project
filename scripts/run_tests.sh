#!/bin/bash
set -e

cd "$(dirname "$0")/.." 

echo "Building common base image..."
docker build -f docker/Dockerfile.base -t test-base .

echo "Building and running test-ls container..."
docker build -f docker/Dockerfile.test_ls -t test-ls .
docker run --rm test-ls

echo ""
echo "Building and running test-python-file container..."
docker build -f docker/Dockerfile.test_python -t test-python-file .
docker run --rm --env-file=jenkins-a/scripts/.env test-python-file
