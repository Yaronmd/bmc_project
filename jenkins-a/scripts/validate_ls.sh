#!/bin/bash

WORD_COUNT=0

for NAME in /scripts/*; do
  BASENAME=$(basename "$NAME")
  COUNT=$(echo "$BASENAME" | sed 's/[-_]/ /g' | wc -w)
  WORD_COUNT=$((WORD_COUNT + COUNT))
done

echo "Total word-like parts in file names: $WORD_COUNT"

if [ "$WORD_COUNT" -gt 3 ]; then
    echo "Condition met. Triggering Jenkins B..."
    /scripts/trigger_jenkins_b.sh && /scripts/monitor_jenkins_b.sh
else
    echo "Condition not met. Jenkins B will not be triggered."
fi
