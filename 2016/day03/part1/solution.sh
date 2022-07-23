#!/usr/bin/env bash

debug() { [[ -n $DEBUG ]] && echo "$@"; }

infile="$1"
valid=0
invalid=0

while read A B C; do
    debug -n "$A,$B,$C "
    if (( A + B > C )) && (( A + C > B )) && (( B + C > A )); then
        debug OK
        valid=$(( valid + 1 ))
    else
        debug NOPE
        invalid=$(( invalid + 1 ))
    fi
done < "$infile"

echo $valid
