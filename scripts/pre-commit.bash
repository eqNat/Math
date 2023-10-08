#!/usr/bin/env bash

echo "Running pre-commit hook"
find "$(dirname "$0")"/.. -type f -name "*\.agda" \
     | tr ' ' '\n' \
     | grep -v "unfinishedProofs.agda" \
     | while read line
do
    agda $line

    STATUS=$?

    if [ $STATUS -ne 0 ]; then
     echo "Pre-commit test failed for $line"
     exit $STATUS
    fi
done