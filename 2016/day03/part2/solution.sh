#!/usr/bin/env bash

debug() { [[ -n $DEBUG ]] && echo "$@"; }

infile="$1"
valid=0
invalid=0

allnums=""

# read in a column at a time and turn it into one long string of numbers
for col in 1 2 3; do
    # embedded echo without quotes normalizes the spacing
    allnums+="$( echo $( awk "{print \$$col}" "$infile" ) ) "
done
debug "Got numbers: $allnums"

while true; do
    read A B C rest <<< "$allnums"

    debug -n "$A,$B,$C "
    if (( A + B > C )) && (( A + C > B )) && (( B + C > A )); then
        debug OK
        valid=$(( valid + 1 ))
    else
        debug NOPE
        invalid=$(( invalid + 1 ))
    fi

    if [[ -z $rest ]]; then
        break
    fi
    allnums="$rest"
done

echo $valid
