#!/usr/bin/env bash

die() { echo "ERROR: $@" >&2; exit 1; }

total_area=0
total_ribbon=0

process_line() {
    local line="$1"
    local l w h area smallest lw wh lh slack volume shortest lpw wph lph ribbon bow

    IFS=x read l w h <<< "$line"
    if (( l == 0 )) || (( w == 0 )) || (( h == 0 )); then
        die "Invalid dimensions: '$line'"
    fi

    #echo "L: $l W: $w H: $h" >&2

    lw=$(( l * w ))
    lpw=$(( l + l + w + w ))
    smallest=$lw
    shortest=$lpw

    wh=$(( w * h ))
    wph=$(( w + w + h + h ))
    if (( wh < smallest )); then
        smallest=$wh
    fi
    if (( wph < shortest )); then
        shortest=$wph
    fi

    lh=$(( l * h ))
    lph=$(( l + l + h + h ))
    if (( lh < smallest )); then
        smallest=$lh
    fi
    if (( lph < shortest )); then
        shortest=$lph
    fi

    area=$(( ( 2 * lw ) + ( 2 * wh ) + ( 2 * lh ) ))
    slack=$smallest
    volume=$(( l * w * h ))
    ribbon=$shortest
    bow=$volume

    total_area=$(( total_area + area + slack ))
    total_ribbon=$(( total_ribbon + ribbon + bow ))
}

while read line; do
    process_line "$line"
done

echo "$total_ribbon"
