#!/bin/bash
# Updates widget data file for ROG Monitor widget
# Runs continuously to feed data to the QML widget

DATA_FILE="/tmp/zephyrus-widget-data.txt"

while true; do
    ~/.local/bin/zephyrus-profile-helper > "$DATA_FILE"
    sleep 2
done
