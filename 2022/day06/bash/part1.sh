#!/usr/bin/env bash

# buffer for the four characters being analyzed
declare -a buffer

declare -i i c=0

while read -n1 ch; do
    if [[ -z $ch ]]; then
        continue
    fi

    # rotate the characters through the buffer
    i=$(( c % 4 ))
    buffer[$i]=$ch
    c+=1

    # this isn't possible during the first three characters
    if (( c < 4 )); then
        continue
    fi

    [[ ${buffer[0]} != ${buffer[1]} ]] &&
        [[ ${buffer[0]} != ${buffer[2]} ]] &&
        [[ ${buffer[0]} != ${buffer[3]} ]] &&
        [[ ${buffer[1]} != ${buffer[2]} ]] &&
        [[ ${buffer[1]} != ${buffer[3]} ]] &&
        [[ ${buffer[2]} != ${buffer[3]} ]] &&
        break
done

echo $c
