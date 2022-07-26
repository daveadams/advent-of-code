#!/usr/bin/env bash

infile="$1"

get_decompressed_length() {
    local s="$1"
    local rv=0
    local ch marker tmpstr charcount repeats sequence seqlen

    while read -n 1 ch; do
        if [[ -z $ch ]]; then
            # we're done with this input
            echo $rv
            return 0
        fi

        if [[ $ch != "(" ]]; then
            # if this isn't an open paren, add one to rv and move to the next character
            rv=$(( rv + 1 ))
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

        # expand $sequence recursively
        seqlen=$( get_decompressed_length "$sequence" )

        # add the length times the repeats
        rv=$(( rv + ( seqlen * repeats ) ))
    done <<< "$s"

    echo "ERROR: not expected to reach this point" >&2
    echo $rv
    return 0
}

get_decompressed_length $( <"$infile" )
