#!/bin/bash
SCRIPT_NAME="backup-script"
SOURCE=$HOME
DESTINATION="/tmp/backup/"


if rsync -avc --delete --exclude='*/' "$SOURCE" "$DESTINATION"; then
    logger -t "$SCRIPT_NAME" "SUCCESS: Файлы синхронизированы"
else
    logger -t "$SCRIPT_NAME" "ERROR: Код возврата: $?"
fi
