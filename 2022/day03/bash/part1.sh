#!/usr/bin/env bash

# ord decodes the ASCII value of a character
ord() { LC_CTYPE=C printf %d "'$1"; }

# decode returns the 'priority' of the given character
# a-z should decode to 1-26
# A-Z should decode to 27-52
decode() {
    if [[ $1 =~ ^[a-z]$ ]]; then
        # 'a' is ASCII 97 so subtract 96
        echo $(( $( ord $1 ) - 96 ))

    elif [[ $1 =~ ^[A-Z]$ ]]; then
        # 'A' is ASCII 65 so subtract 38
        echo $(( $( ord $1 ) - 38 ))
    else
        echo 0
    fi
}

# uniq_chars returns a sorted list, one character per line, of all unique
# characters in a string
uniq_chars() { grep -o . <<< "$1" |sort -u; }

# shared_char returns any shared characters between two strings
shared_char() {
    {
        uniq_chars "$1"
        uniq_chars "$2"
    } \
        | sort \
        | uniq -c \
        | awk '$1==2{print $2}'
}

declare -i sum=0
while read line; do
    len=$(( ${#line} / 2 ))
    compartment1=${line:0:$len}
    compartment2=${line:$len}

    ch=$( shared_char "$compartment1" "$compartment2" )
    sum+=$( decode $ch )
done

echo $sum
