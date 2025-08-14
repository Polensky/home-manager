#!/bin/bash

# Set battery device
BAT="BAT0"  

# Get battery percentage
PERCENT=$(cat /sys/class/power_supply/$BAT/capacity)

# Get battery status
STATUS=$(cat /sys/class/power_supply/$BAT/status)

# Choose emoji based on status
if [[ "$STATUS" == "Charging" ]]; then
    EMOJI="🔌"
elif [[ "$STATUS" == "Discharging" ]]; then
    EMOJI="🔋"
elif [[ "$STATUS" == "Full" ]]; then
    EMOJI="✅"
else
    EMOJI="❓"
fi

notify-send "${EMOJI} ${PERCENT}%"
