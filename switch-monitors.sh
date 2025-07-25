#!/bin/bash

CONFIG="$HOME/.config/hypr/hyprland.conf"

# Check if DP-1 is enabled
if grep -A5 "output = DP-1" "$CONFIG" | grep -q "disabled = false"; then
    # Switch to HDMI-A-1
    sed -i 's/output = DP-1/output = DP-1/; /output = DP-1/,/}/ s/disabled = false/disabled = true/' "$CONFIG"
    sed -i 's/output = HDMI-A-1/output = HDMI-A-1/; /output = HDMI-A-1/,/}/ s/disabled = true/disabled = false/' "$CONFIG"
else
    # Switch to DP-1
    sed -i 's/output = DP-1/output = DP-1/; /output = DP-1/,/}/ s/disabled = true/disabled = false/' "$CONFIG"
    sed -i 's/output = HDMI-A-1/output = HDMI-A-1/; /output = HDMI-A-1/,/}/ s/disabled = false/disabled = true/' "$CONFIG"
fi

hyprctl reload
