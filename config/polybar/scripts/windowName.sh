#!/bin/bash

WM_DESKTOP=$(xdotool getwindowfocus)

if [ $WM_DESKTOP == "496" ]; then

	echo "Desktop"

elif [ $WM_DESKTOP != "1883" ]; then

	WM_CLASS=$(xprop -id $(xdotool getactivewindow) WM_CLASS | awk 'NF {print $NF}' | sed 's/"/ /g')
	#WM_NAME=$(xprop -id $(xdotool getactivewindow) WM_NAME | cut -d '=' -f 2 | awk -F\" '{ print $2 }')
	#kitty
	#if [ $WM_CLASS == 'kitty' ]; then
		#echo "kitty"
	#everything else
	if [ $WM_CLASS == 'Brave-browser' ]; then
		echo "brave"
	else
		echo "$WM_CLASS"
	fi

fi
