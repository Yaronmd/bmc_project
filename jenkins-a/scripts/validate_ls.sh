#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"
TRIGGER_SCRIPT="$SCRIPT_DIR/trigger_jenkins_b.sh"
MONITOR_SCRIPT="$SCRIPT_DIR/monitor_jenkins_b.sh"
TARGET_DIR="$SCRIPT_DIR/data"

echo "DEBUG: Listing files in $TARGET_DIR"
ls -l "$TARGET_DIR"

WORD_COUNT=0

for NAME in "$TARGET_DIR"/*; do
  BASENAME=$(basename "$NAME")
  COUNT=$(echo "$BASENAME" | sed 's/[-_]/ /g' | wc -w)
  echo "DEBUG: $BASENAME → $COUNT parts"
  WORD_COUNT=$((WORD_COUNT + COUNT))
done

echo "Total word-like parts in file names: $WORD_COUNT"

if [ "$WORD_COUNT" -gt 3 ]; then
    echo "Condition met. Triggering Jenkins B..."
    "$TRIGGER_SCRIPT" && "$MONITOR_SCRIPT"
else
    echo "Condition not met. Jenkins B will not be triggered."
fi
