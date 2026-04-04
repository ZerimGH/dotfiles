#!/usr/bin/env bash

TEMP_FILE=$(mktemp /tmp/screenshot_XXXXXX.png)

grimshot savecopy anything "$TEMP_FILE"

mkdir -p "$HOME/Pictures/Screenshots"
FILE_NAME="$HOME/Pictures/Screenshots/$(date +%d-%m-%y-%H_%M_%S).png"
TARGET_FILE=$(zenity --file-selection --save --filename="$FILE_NAME")

if [ -n "$TARGET_FILE" ]; then
  mv "$TEMP_FILE" "$TARGET_FILE"
else
  rm -f "$TEMP_FILE"
fi
