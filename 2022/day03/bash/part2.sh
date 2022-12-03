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

# shared_char returns any shared characters between multiple strings
shared_char() {
    local s
    for s in "$@"; do
        uniq_chars "$s"
    done \
        | sort \
        | uniq -c \
        | awk '$1=='"$#"'{print $2}'
}

declare -i sum=0
while read line1; do
    read line2
    read line3

    badge=$( shared_char "$line1" "$line2" "$line3" )
    sum+=$( decode $badge )
done

echo $sum
