#!/usr/bin/env bash

direction=N
locx=0
locy=0

# history will be denoted by a series of location pairs notated as "x,y"
# each pair will be separated by a colon, eg, a history might be:
#     :0,0:0,1:0,2:
# so it would be possible to check for a location with grep -q ":$x,$y:"
loc_history=":"

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

wrap_up() {
    if (( locx < 0 )); then
        locx=$(( locx * -1 ))
    fi

    if (( locy < 0 )); then
        locy=$(( locy * -1 ))
    fi

    echo $(( locx + locy ))
    exit 0
}

check_location() {
    if grep -q ":$locx,$locy:" <<< "$loc_history"; then
        wrap_up
    fi
}

forward() {
    local blocks=$1
    case "$direction" in
        N)
            for i in $( seq 1 $blocks ); do
                locy=$(( locy + 1 ))
                check_location
                loc_history+="$locx,$locy:"
            done
            ;;

        E)
            for i in $( seq 1 $blocks ); do
                locx=$(( locx + 1 ))
                check_location
                loc_history+="$locx,$locy:"
            done
            ;;

        S)
            for i in $( seq 1 $blocks ); do
                locy=$(( locy - 1 ))
                check_location
                loc_history+="$locx,$locy:"
            done
            ;;
        W)
            for i in $( seq 1 $blocks ); do
                locx=$(( locx - 1 ))
                check_location
                loc_history+="$locx,$locy:"
            done
            ;;
    esac
}

input=$( sed 's/, / /g' "$1" )
loc_history+="$locx,$locy:"

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

die "OOOOPS"
