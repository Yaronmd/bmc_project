#!/bin/bash
set -e

if [ ! -f /tmp/hello_bmc.txt ]; then
    echo "ERROR: File /tmp/hello_bmc.txt was not created"
    exit 1
fi

if ! grep -q "Hello BMC" /tmp/hello_bmc.txt; then
    echo "ERROR: 'Hello BMC' not found in /tmp/hello_bmc.txt"
    exit 1
fi

echo "File /tmp/hello_bmc.txt created and contains 'Hello BMC'"
