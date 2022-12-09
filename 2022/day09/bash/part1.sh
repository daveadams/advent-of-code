#!/usr/bin/env bash

# head position
declare -i hx=0 hy=0

# tail position
declare -i tx=0 ty=0

# history of tail movements
declare -A tail_trail
tail_trail[x=$tx,y=$ty]=1

# move adjusts the position of the head by one position
move() {
    case "$1" in
        U) hy+=1 ;;
        D) hy+=-1 ;;
        L) hx+=-1 ;;
        R) hx+=1 ;;
    esac
}

# adjust_tail checks the tail position and if either the x or y coordinate is
# more than one space out of place, it adjusts both the x and y coordinate of
# the tail by one or zero to get it closer to the head. If the tail moves, the
# tail_trail variable is updated with the new location.
adjust_tail() {
    local -i xdiff=$(( hx - tx ))
    local -i ydiff=$(( hy - ty ))

    # if abs(xdiff) <= 1 and abs(ydiff) <= 1 then no adjustment is needed
    (( xdiff <= 1 )) \
        && (( ydiff <= 1 )) \
        && (( xdiff >= -1 )) \
        && (( ydiff >= -1 )) \
        && return 0

    case "$xdiff" in
        1|2)   tx+=1  ;;
        -1|-2) tx+=-1 ;;
    esac

    case "$ydiff" in
        1|2)   ty+=1  ;;
        -1|-2) ty+=-1 ;;
    esac

    tail_trail[x=$tx,y=$ty]=1
    return 0
}

declare -i distance i
while read direction distance; do
    for (( i = 0; i < $distance; i++ )); do
        move $direction
        adjust_tail
    done
done

# print the count of unique tail positions
echo "${#tail_trail[@]}"
