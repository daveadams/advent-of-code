#!/usr/bin/env bash

declare -a buffer
declare -i i c=0
declare -i -r BUFFER_LENGTH=14

while read -n1 ch; do
    # rotate the characters through the buffer
    i=$(( c % BUFFER_LENGTH ))
    buffer[$i]=$ch
    c+=1

    # this isn't possible during the first BUFFER_LENGTH characters
    (( c < BUFFER_LENGTH )) && continue

    # compare all the combinations
    for (( x = 0; x < BUFFER_LENGTH - 1; x++ )); do
        for (( y = x + 1; y < BUFFER_LENGTH; y++ )); do
            if [[ ${buffer[$x]} == ${buffer[$y]} ]]; then
                # continue the topmost loop
                continue 3
            fi
        done
    done
    break
done

echo $c
