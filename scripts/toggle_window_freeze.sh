#!/bin/bash

PID=$(hyprctl activewindow -j | jq -r '.pid')

if [ -z "$PID" ] || [ "$PID" = "null" ]; then
	exit 0
fi

STATE=$(ps -o state= -p "$PID" 2>/dev/null)

if [ "$STATE" = "T" ]; then
	kill -CONT "$PID"
else
	kill -STOP "$PID"
fi
