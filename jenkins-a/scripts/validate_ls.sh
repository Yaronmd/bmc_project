#!/bin/bash

TARGET_DIR=./scripts/data
mkdir -p "$TARGET_DIR"

if [ ! -d "$TARGET_DIR" ]; then
  echo "ERROR: $TARGET_DIR does not exist"
  exit 1
fi

WORD_COUNT=0

echo "DEBUG: Listing files in $TARGET_DIR"
ls -l "$TARGET_DIR"

for NAME in "$TARGET_DIR"/*; do
  [ -f "$NAME" ] || continue  
  BASENAME=$(basename "$NAME")
  COUNT=$(echo "$BASENAME" | sed 's/[-_]/ /g' | wc -w)
  echo "DEBUG: $BASENAME → $COUNT parts"

  WORD_COUNT=$((WORD_COUNT + COUNT))
done

echo "Total word-like parts in file names: $WORD_COUNT"

if [ "$WORD_COUNT" -gt 3 ]; then
    echo "Condition met. Triggering Jenkins B..."
    "$TARGET_DIR/trigger_jenkins_b.sh" && "$TARGET_DIR/monitor_jenkins_b.sh"
else
    echo "Condition not met. Jenkins B will not be triggered."
fi
