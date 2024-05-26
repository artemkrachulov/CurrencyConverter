#!/bin/bash
swift-format --version 1>/dev/null 2>&1
if [ $? -eq 0 ]
then
    git diff --diff-filter=d --staged --name-only | grep -e '\(.*\).swift$' | while read line; do
        swift-format -i "${line}";
        git add "$line";
    done
fi
