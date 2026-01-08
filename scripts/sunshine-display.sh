#!/bin/bash

CONFIG="$HOME/.config/hypr/monitors.conf"

# Check if DP-1 is enabled
if grep -A5 "output = DP-1" "$CONFIG" | grep -q "disabled = false"; then
	# Switch to HDMI-A-1
	sed -i "/output = DP-1/,/}/ s/disabled = false/disabled = true/" "$CONFIG"
	sed -i "/output = HDMI-A-1/,/}/ s/disabled = true/disabled = false/" "$CONFIG"
	sed -i "/output = HDMI-A-1/,/}/ s/mode = 1920x1080@120/mode = ${SUNSHINE_CLIENT_WIDTH}x${SUNSHINE_CLIENT_HEIGHT}@${SUNSHINE_CLIENT_FPS}/" "$CONFIG"
	if [ "$SUNSHINE_CLIENT_HDR" = "true" ]; then
		sed -i "/output = HDMI-A-1/,/}/ s/cm = srgb/cm = hdr/" "$CONFIG"
	fi
	hyprctl reload
else
	# Switch to DP-1
	sed -i "/output = DP-1/,/}/ s/disabled = true/disabled = false/" "$CONFIG"
	sed -i "/output = HDMI-A-1/,/}/ s/disabled = false/disabled = true/" "$CONFIG"
	sed -i "/output = HDMI-A-1/,/}/ s/mode = ${SUNSHINE_CLIENT_WIDTH}x${SUNSHINE_CLIENT_HEIGHT}@${SUNSHINE_CLIENT_FPS}/mode = 1920x1080@120/" "$CONFIG"
	if [ "$SUNSHINE_CLIENT_HDR" = "true" ]; then
		sed -i "/output = HDMI-A-1/,/}/ s/cm = hdr/cm = srgb/" "$CONFIG"
	fi
	hyprctl reload
	sleep 3 && systemctl suspend
fi
