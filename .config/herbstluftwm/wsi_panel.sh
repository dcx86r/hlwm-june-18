#!/bin/sh
# workspace icons panel
# parent (autostart) handles cleanup on WM exit/reload

# source herbstclient function
rpath="$HOME/.config/herbstluftwm"
. $rpath/hlc_fnct.sh

ICON() {
	case $1 in
		active) printf '%s' "^i(/tmp/coin.xpm)"       ;;
		not_empty) printf '%s' "^i(/tmp/mbox.xpm)"    ;;
		urgent) printf '%s' "^i(/tmp/mbox_urgnt.xpm)" ;;
		empty) 	printf '%s' "^i(/tmp/gray_box.xpm)"   ;;
	esac
}

# caching icons on tmpfs
i_path="$rpath/icons"
[ ! -e /tmp/coin.xpm ] && \
cp $i_path/coin.xpm \
$i_path/mbox.xpm \
$i_path/mbox_urgnt.xpm \
$i_path/gray_box.xpm \
/tmp/ 2> $i_path/../dzen_err.log

dzen_bg="#342F2F"
dzen_fg="#000000"
dzen_font="tamsyn 16"

tags=$(HC tag_status)
tag_count=$(printf '%s' "$tags" | awk '{print NF}')
mon_yl=$(printf '%s' "$(HC monitor_rect 0)" | cut -d' ' -f4)
# bar length using 16px icons, 4px space (x2)
bar_xl=$(($tag_count * (16 + 4*2)))

HC --idle | {
	while true; do
		printf '%s' "$tags" | sed -n 's/^.//p' | \
		tr '\t' '\n' | while read full_tag; do
			case $full_tag in
				\#*)dzenstx=$(ICON active)    ;;
				:*) dzenstx=$(ICON not_empty) ;;
				!*) dzenstx=$(ICON urgent)    ;;
				*) dzenstx=$(ICON empty)      ;;
			esac
			tag=$(printf '%s' "$full_tag" | tr -d '[:punct:]')
			printf '%s' " ^ca(1, herbstclient use $tag)$dzenstx^ca()"
		done
		printf '%s\n'
		read hook || exit
		case "$hook" in
			tag*) tags=$(HC tag_status) ;;
		esac
	done
} | dzen2 -fn "$dzen_font" -ta l -sa l -fg "$dzen_fg" -bg "$dzen_bg" \
-h 25 -w "$bar_xl" -y "$mon_yl" -x 0
