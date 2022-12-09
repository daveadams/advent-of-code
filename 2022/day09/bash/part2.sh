#!/usr/bin/env bash

TAIL_LENGTH=9

# rope positions
declare -i -a x y
for (( i = 0; i <= TAIL_LENGTH; i++ )); do
    x[$i]=0
    y[$i]=0
done

# history of tail movements
declare -A tail_trail
tail_trail[x=0,y=0]=1

# move adjusts the position of the head by one position
move() {
    case "$1" in
        U) y[0]+=1 ;;
        D) y[0]+=-1 ;;
        L) x[0]+=-1 ;;
        R) x[0]+=1 ;;
    esac
}

# adjust_tail checks the tail position and for each segment, if either the x
# or y coordinate is more than one space out of place, it adjusts both the x
# and y coordinate of the tail by one or zero to get it closer to the head.
# If the tail moves, the tail_trail variable is updated with the new location.
adjust_tail() {
    local -i segment xdiff ydiff

    for (( segment = 1; segment <= TAIL_LENGTH; segment++ )); do
        xdiff=$(( ${x[$(( segment - 1 ))]} - ${x[$segment]} ))
        ydiff=$(( ${y[$(( segment - 1 ))]} - ${y[$segment]} ))

        # if abs(xdiff) <= 1 and abs(ydiff) <= 1 then no adjustment is needed
        (( xdiff <= 1 )) \
            && (( ydiff <= 1 )) \
            && (( xdiff >= -1 )) \
            && (( ydiff >= -1 )) \
            && break

        case "$xdiff" in
            1|2)   x[$segment]+=1  ;;
            -1|-2) x[$segment]+=-1 ;;
        esac

        case "$ydiff" in
            1|2)   y[$segment]+=1  ;;
            -1|-2) y[$segment]+=-1 ;;
        esac
    done
}

declare -i distance i
while read direction distance; do
    for (( i = 0; i < $distance; i++ )); do
        move $direction
        adjust_tail
        tail_trail[x=${x[$TAIL_LENGTH]},y=${y[$TAIL_LENGTH]}]=1
    done
done

# print the count of unique tail positions
echo "${#tail_trail[@]}"
