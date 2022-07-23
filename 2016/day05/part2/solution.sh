#!/usr/bin/env bash

door_id="$1"

declare -a pwchars

numchars=0

# shut off stderr to avoid ugly "signal: broken pipe" error message
exec 2>&-

{
    for n in $( seq 1 999999 ); do
        echo "$door_id$n"
    done
    for m in $( seq 1 999999 ); do
        echo "${m},000,000 hashes completed" >&2
        for n in $( seq 0 999999 ); do
            printf "%s%d%06d\n" $door_id $m $n
        done
    done
} | go run md5-per-line.go | grep --line-buffered ^00000 \
    | while read line; do
        pos=$( cut -c6 <<< "$line" )
        echo "OHAI: $pos -- $line" >&2
        # if this isn't a 0 through 7, keep going
        if ! [[ $pos =~ [0-7] ]]; then
            echo "  BAD POSITION" >&2
            continue
        fi
        # if we already have a character at this location, keep going
        if [[ -n ${pwchar[$pos]} ]]; then
            echo "  POSITION TAKEN" >&2
            continue
        fi
        char=$( cut -c7 <<< "$line" )
        echo "DEBUG: GOT CHAR '$char' AT $pos" >&2
        pwchar[$pos]="$char"
        numchars=$(( numchars + 1 ))
        if (( numchars == 8 )); then
            # print the password
            for i in {0..7}; do
                echo -n "${pwchar[$i]}"
            done
            echo
            exit
        fi
    done
