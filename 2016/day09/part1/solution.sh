#!/usr/bin/env bash

infile="$1"
outstr=""
count=0

while read -n 1 ch; do
    if [[ -z $ch ]]; then
        # we're done
        break
    fi
    if [[ $ch != "(" ]]; then
        outstr+="$ch"
        count=$(( count + 1 ))
        continue
    fi
    # ch was '(', so read to the next ')' into $marker
    # this command consumes the ')' but doesn't include it in the read var
    read -d ")" marker

    # parse the marker which is in the form NxM
    # N is the number of characters to read
    # M is the number of types to print the character sequence
    IFS=x read charcount repeats <<< "$marker"

    # read charcount characters into $sequence
    read -n $charcount sequence

    # append $sequence to the $outstr $charcount times
    for i in $( seq 1 $repeats ); do
        outstr+="$sequence"
        count=$(( count + ${#sequence} ))
    done
done < "$infile"
#echo $outstr
echo $count
