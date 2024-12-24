#!/bin/bash
# Example script to test the beengone command
# Loops while checking idle time with a minimum threshold before executin a command
cd $(git rev-parse --show-toplevel)/build/Debug

# Works while screen saver is running
open /System/Library/CoreServices/ScreenSaverEngine.app

while true; do
    ./beengone -m 3s
    if [[ $? -eq 0 ]]; then
        osascript -e 'tell application "ScreenSaverEngine" to quit'
        break
    fi
    sleep 1
done

# Pause a timer when there's no activity for a set time
timer=-1

while true; do
    ./beengone -m 5m
    if [[ $? -eq 0 ]]; then
        # Could be `shortcuts` or any command
        result=$(osascript -e "display dialog "End Timer?" buttons {"END", "CONTINUE"} default button "CONTINUE"" 2>/dev/null)
        if [[ $result =~ END ]]; then
            break
        fi
    fi
    sleep 1
    timer=$((timer+1))
done

osascript -e "display alert \"Timer: $timer seconds\" message \"Timer Ended\" giving up after 5"