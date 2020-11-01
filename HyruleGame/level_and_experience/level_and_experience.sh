#!/bin/bash

hp=$1
current_xp=$2
next_level=$3
current_level=$4
mob_name=$5
array=$6
gain=0

case $mob_name in
    Ganon)
	xp=150
	;;
    *)
	xp=15
	;;
esac

gain=$xp

if [[ $(($current_xp+$xp)) -ge $next_level ]]; then

    current_level=$((current_level+1))

    next=1
    
    case $current_level in
	1)
	    hp=$((hp+10))
	    ;;
	2)
	    hp=$((hp+15))
	    ;;
	3)
	    hp=$((hp+20))
	    ;;
	4)
	    hp=$((hp+25))
	    ;;
	5)
	    hp=$((hp+30))
	    ;;
	*)
	    hp=$((hp+5))
	    ;;
    esac

    final_xp=$((($xp+$current_xp)-$next_level))
    next_level=$((next_level+15))
else
    final_xp=$(($current_xp+$xp))
    next=0
fi

array=("$final_xp" "$hp" "$next_level" "$current_level" "$gain" "$next")
