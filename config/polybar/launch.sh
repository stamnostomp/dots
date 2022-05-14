#!/bin/bash

# kill already running bar 

killall -q polybar

# Launch polybar uning default config location ~/.config/polybar/config.ini

polybar primary 2>&1 | tee -a /tmp/polybar.log & 
polybar secondary &

echo "Polybar launched ..."
