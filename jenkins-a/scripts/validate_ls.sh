#!/bin/bash

WORD_COUNT=$(ls /scripts | wc -w)
echo "Word count: $WORD_COUNT"

if [ "$WORD_COUNT" -gt 3 ]; then
    echo "Enough files, triggering Jenkins B..."
    /scripts/trigger_jenkins_b.sh
else
    echo "Not enough files to trigger Jenkins B."
fi
