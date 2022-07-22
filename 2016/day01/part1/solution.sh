#!/usr/bin/env bash

direction=N
locx=0
locy=0

die() { echo "ERROR: $*" >&2; exit 1; }

turn_left() {
    case "$direction" in
        N) direction=W ;;
        E) direction=N ;;
        S) direction=E ;;
        W) direction=S ;;
    esac
}

turn_right() {
    case "$direction" in
        N) direction=E ;;
        E) direction=S ;;
        S) direction=W ;;
        W) direction=N ;;
    esac
}

forward() {
    local blocks=$1
    case "$direction" in
        N) locy=$(( locy + blocks )) ;;
        E) locx=$(( locx + blocks )) ;;
        S) locy=$(( locy - blocks )) ;;
        W) locx=$(( locx - blocks )) ;;
    esac
}

input=$( sed 's/, / /g' "$1" )

for move in $input; do
    turn=$( cut -c1 <<< "$move" )
    distance=$( cut -c2- <<< "$move" )

    case "$turn" in
        R) turn_right ;;
        L) turn_left ;;
        *) die "BAD DATA" ;;
    esac

    forward "$distance"
done

if (( locx < 0 )); then
    locx=$(( locx * -1 ))
fi

if (( locy < 0 )); then
    locy=$(( locy * -1 ))
fi

echo $(( locx + locy ))
