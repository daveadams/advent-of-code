#!/usr/bin/env bash

infile="$1"

count=0

while read line; do
    #echo -n $line

    # use awk to split each line into multiple lines for each part,
    # prefixed by 'super' for supernet parts of the address and
    # 'hyper' for hypernet parts of the address.
    split=$( awk -F '[][]' '{for(i=1;i<=NF;i++) { print (i%2?"super":"hyper"), $i }}' <<< "$line" )

    # find any aba sequences in the supernet parts of the address
    abas=$(
        # for each segment, we need all the ABA patterns, including any
        # overlaps, so for each segment we will print the original string
        # and then trim off the first letter, then the first two letters,
        # etc, down to a three character string, and then run the appropriate
        # grep|grep|sort pipeline on the results
        for segment in $( awk '$1=="super"{print $2}' <<< "$split" ); do
            # ${#var} gives the string length of $var
            for pos in $( seq 0 $(( ${#segment} - 3 )) ); do
                # ${var:n} prints the substring of $var starting at position n
                echo "${segment:$pos}"
            done
        done \
            | grep -oE "([a-z])[a-z]\1" \
            | grep -vEx "([a-z])\1\1" \
            | sort -u
    )

    #echo -n ,$abas

    if [[ -z $abas ]]; then
        # no ABAs were found, so skip to the next input line
        #echo ",,NONE"
        continue
    fi

    #echo "ABAs:"
    #echo "$abas"
    #echo

    # generate babs
    babs=$(
        while read aba; do
            # ${var:1:1} prints the single character at position 1
            # ${var:0:1} prints the single character at position 0
            echo "${aba:1:1}${aba:0:1}${aba:1:1}"
        done <<< "$abas"
    )

    #echo -n ,$babs

    # if any aba sequence is in a hypernet part of the address, then
    # the address supports SSL.
    #
    # grep options:
    #   -q means don't print anything, just exit nonzero if there's no match
    #   -F means don't do any pattern matching, just look for the exact strings
    #   -f <file> means load a list of patterns to match from a file
    #   <( ... ) means to take the output of the command inside the parens, and
    #      present it as a file for some other command to read in (useful if the
    #      other command expects a file, rather than a stream on stdin, or if you
    #      want the input process to be in a subprocess rather than using a pipe)
    #
    if grep -qFf <( echo "$babs" ) <( awk '$1=="hyper"{print $2}' <<< "$split" ); then
        #echo ,MATCHY
        count=$(( count + 1 ))
    #else
        #echo ,NOPE
    fi
done < "$infile"

echo $count
