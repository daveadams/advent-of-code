#!/usr/bin/env bash

die() { echo "ERROR: $@" >&2; exit 1; }

total_area=0

process_line() {
    local line="$1"
    local l w h area smallest lw wh lh slack

    IFS=x read l w h <<< "$line"
    if (( l == 0 )) || (( w == 0 )) || (( h == 0 )); then
        die "Invalid dimensions: '$line'"
    fi

    #echo "L: $l W: $w H: $h" >&2

    lw=$(( l * w ))
    smallest=$lw

    wh=$(( w * h ))
    if (( wh < smallest )); then
        smallest=$wh
    fi

    lh=$(( l * h ))
    if (( lh < smallest )); then
        smallest=$lh
    fi

    area=$(( ( 2 * lw ) + ( 2 * wh ) + ( 2 * lh ) ))
    slack=$smallest

    total_area=$(( total_area + area + slack ))
}

while read line; do
    process_line "$line"
done

echo "$total_area"
