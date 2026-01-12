#!/bin/bash

TRIGGER_NAME="CUSTOM_TRIGGER"
SLEEP_TIME=5
CURRENT_STATE=""

while true; do
	if pgrep -f "$TRIGGER_NAME" > /dev/null; then
		if [ "$CURRENT_STATE" != "Gaming" ]; then
			lact cli profile set Gaming
			powerprofilesctl set performance
			qs -c noctalia-shell ipc call notifications enableDND
			qs -c noctalia-shell ipc call idleInhibitor enable
			CURRENT_STATE="Gaming"
		fi
	else
		if [ "$CURRENT_STATE" != "Default" ]; then
			lact cli profile set Default
			powerprofilesctl set power-saver
			qs -c noctalia-shell ipc call notifications disableDND
			qs -c noctalia-shell ipc call idleInhibitor disable
			CURRENT_STATE="Default"
		fi
	fi
	sleep $SLEEP_TIME
done
