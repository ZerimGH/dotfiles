#!/usr/bin/env bash

TEMP_FILE=$(mktemp /tmp/screenshot_XXXXXX.png)

SAVED=$(grimshot savecopy anything "$TEMP_FILE")

if [ $SAVED != "" ]; then
    mkdir -p "$HOME/Pictures/Screenshots"
    FILE_NAME="$HOME/Pictures/Screenshots/$(date +%d-%m-%y-%H_%M_%S).png"
    TARGET_FILE=$(zenity --file-selection --save --filename="$FILE_NAME")
    mv "$SAVED" "$TARGET_FILE"
else
    rm -f "$TEMP_FILE"
fi


