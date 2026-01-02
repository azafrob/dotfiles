#!/bin/sh

TRIGGER_NAME="CUSTOM_TRIGGER"
SLEEP_TIME=5
CURRENT_STATE=""

while true; do
    if pgrep -f "$TRIGGER_NAME" > /dev/null; then
        if [ "$CURRENT_STATE" != "Gaming" ]; then
            lact cli profile set Gaming || true
            powerprofilesctl set performance
            CURRENT_STATE="Gaming" # Actualizamos el estado
        fi
    else
        if [ "$CURRENT_STATE" != "Default" ]; then
            lact cli profile set Default || true
            powerprofilesctl set power-saver
            CURRENT_STATE="Default" # Actualizamos el estado
        fi
    fi
    sleep $SLEEP_TIME
done
