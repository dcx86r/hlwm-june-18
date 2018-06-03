#!/bin/bash

# source herbstclient function
rpath="$HOME/.config/herbstluftwm"
. $rpath/hlc_fnct.sh

blur=5
wallpaper=$(sed -n 2p < ~/.fehbg | cut -d ' ' -f 3)

ROOT() {
  clients=$(HC attr tags.focus.client_count)
  frames=$(HC attr tags.focus.frame_count)
  empty=( $(xdotool getmouselocation --shell) )
  what=$(echo "${empty[3]}" | cut -d'=' -f2)
  if [ "$what" -eq "172" ] && [ "$clients" -lt "2" ]; then
	echo "$wallpaper"
  else
	if [ "$clients" -ge "1" ] ; then
     		echo "--blur $blur $wallpaper"
	else
		echo "$wallpaper"
  	fi
fi
}

# watch for relevant hooks and take action
HC --idle 'focus_changed|window_title_changed' | while read hook; do
	eval setroot "$(ROOT 0)" &
done
