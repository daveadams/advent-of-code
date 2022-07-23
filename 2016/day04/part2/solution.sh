#!/usr/bin/env bash

debug() { [[ -n $DEBUG ]] && echo "$@"; }

infile="$1"

# helper functions to convert from character strings to ASCII and back
#   from https://unix.stackexchange.com/questions/92447/bash-script-to-get-ascii-values-for-alphabet
ascii_to_char() { printf "\\$(printf '%03o' "$1")"; }
char_to_ascii() { LC_CTYPE=C printf '%d' "'$1"; }

# ASCII value of 'a' (97) serves as the offset we need to
# convert our decryption below back to ASCII characters
ASCII_OFFSET=$( char_to_ascii 'a' )

# helper functions for decrypting room names
char_to_position() { echo -n "$(( $( char_to_ascii "$1" ) - 97 ))"; }
position_to_char() { echo -n "$( ascii_to_char "$(( $1 + 97 ))" )"; }

while read line; do
    # example line: aaaaa-bbb-z-y-x-123[abxyz]
    #   room is 'aaaaa-bbb-z-y-x'
    #   sector_id is '123'
    #   given_checksum is 'abxyz'

    # cut the sector/checksum off (reverse string, field 1 (split on '-'), reverse)
    idsum=$( rev <<< "$line" | cut -d- -f1 | rev )
    # cut just the room off (reverse string, fields 2-END (split on '-'), reverse )
    room=$( rev <<< "$line" | cut -d- -f2- | rev )

    # sector_id is just the number before the checksum in $idsum
    # so, split at '[' and take the first field
    sector_id=$( cut -d'[' -f1 <<< "$idsum" )

    # given_checksum is the bit between the brackets
    # so take field 2 when split at '[' then trim the ']'
    given_checksum=$( cut -d'[' -f2- <<< "$idsum" | tr -d ']' )

    debug "line = '$line'"
    debug "room = '$room'"
    debug "sector = '$sector_id'"
    debug "checksum = '$given_checksum'"

    # to get letter frequency, filter out '-' from $room using sed, then print each
    # letter on its own line, and use these commands to generate the checksum:
    #
    #   sort | uniq -c | sort -b -t ' ' -k 1nr | awk '{print $2}' | head -n 5
    #
    # uniq -c prints each character it finds and the number of times it appears in a row.
    #
    # sort options (see `man sort` for more details):
    #   -b ignore leading spaces when calculating field nums
    #   -t field separator character (space, in our case)
    #   -k field sort definition, with modifiers (see `man sort`)
    #        1nr,2 -- sort by field 1, numeric and reverse order
    #
    # awk '{print $2}' will print just the second field of the given input, for
    # awk's default definition of fields, which ignores leading whitespace and
    # collapses any amount of whitespace down to a single field break
    #
    # head -n 5 prints only the first five lines
    #
    # wrapping the command in a bare "echo $( ... )" will then eliminate any
    # line breaks, and a final `sed` can remove the spaces from the properly
    # ordered checksum.

    generated_checksum=$(
        echo $(
            while read -n 1 ch; do
                echo $ch
            done <<< "$( sed s/-//g <<< "$room" )" \
                |sed '/^$/d' |sort |uniq -c |sort -b -t' ' -k 1rn |awk '{print $2}' |head -n 5
        ) | sed 's/ //g'
    )
    debug "generated checksum = '$generated_checksum'"

    if [[ $generated_checksum != $given_checksum ]]; then
        continue
    fi

    # decrypt room name
    echo -n "$sector_id "
    while read -n 1 ch; do
        # if its empty, ignore
        if [[ -z $ch ]]; then
            continue
        fi

        # if it's a dash, print a space
        if [[ $ch == - ]]; then
            echo -n ' '
            continue
        fi

        # get the position in the alphabet of the character
        apos=$( char_to_position "$ch" )

        # add the sector_id and mod by 26 to rotate thru the alphabet
        newpos=$(( ( apos + sector_id ) % 26 ))

        # print the decrypted character
        echo -n "$( position_to_char "$newpos" )"
    done <<< "$room"
    echo
done < "$infile"
