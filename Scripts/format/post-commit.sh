#!/bin/bash
swift-format --version 1>/dev/null 2>&1
if [ $? -eq 0 ]
then
    git diff --name-only HEAD HEAD~1 | grep -e '\(.*\).swift$' | while read line; do
        swift-format -i "${line}";
    done
fi
