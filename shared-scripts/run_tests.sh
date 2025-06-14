#!/bin/bash
set -e

WORKSPACE="/var/jenkins_home/workspace/job-a"

echo "Building common base image..."
docker build -f ${WORKSPACE}/docker/Dockerfile.base -t test-base ${WORKSPACE}

echo "Building and running test-ls container..."
docker build -f ${WORKSPACE}/docker/Dockerfile.test_ls -t test-ls ${WORKSPACE}
docker run --rm test-ls

echo ""
echo "Building and running test-python-file container..."
docker build -f ${WORKSPACE}/docker/Dockerfile.test_python -t test-python-file ${WORKSPACE}
docker run --rm test-python-file
