#!/bin/bash

(exec -a CUSTOM_TRIGGER tail -f /dev/null) &
TRIGGER_PID=$!
"$@" &
MASTER_PID=$!
cleanup() {
	kill $TRIGGER_PID 2>/dev/null
}
trap cleanup EXIT
wait $MASTER_PID
