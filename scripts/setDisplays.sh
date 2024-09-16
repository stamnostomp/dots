#!/usr/bin/env sh

xrandr --output DP-0 --primary --brightness 1.1 --rate 144.00
xrandr --output HDMI-0 --rate 75.00 --above DP-0
#xrandr --output HDMI-1 --right-of DP-0
