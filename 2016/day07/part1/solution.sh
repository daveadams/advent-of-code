#!/usr/bin/env bash

infile="$1"

count=0

while read line; do
    # use awk to split each line into multiple lines for each part,
    # prefixed by 'normal' for regular parts of the address and
    # 'hyper' for hypernetwork parts of the address.
    split=$( awk -F '[][]' '{for(i=1;i<=NF;i++) { print (i%2?"normal":"hyper"), $i }}' <<< "$line" )

    # pipe the hyper lines through grep; if any match the ABBA pattern,
    # this address does not support TLS, so continue with the next line
    #
    # pipeline explanation:
    #   First, use awk to print the address segment from the lines starting with 'hyper'.
    #   awk splits on whitespace by default, so a line reading 'hyper xyzzy' would print
    #   'xyzzy'. The `<<< "$split"` sends the contents of the $split variable into the
    #   command's standard input.
    #
    #     awk '$1 == "hyper" { print $2 }' <<< "$split"
    #
    #   Then use grep to match the ABBA pattern. `-E` uses extended regular expressions,
    #   which can use backreferences, eg using `\2` to say "match the exact value that
    #   was matched by the second parenthesized segment of the regex". `-o` prints all
    #   matches grep finds, one per line, just the matched part.
    #
    #     grep -oE "([a-z])([a-z])\2\1"
    #
    #   Then use grep again to rule out the 'aaaa' possibility which would match the regex
    #   but is not a valid ABBA. In this case, use `-v` to *not* print any lines that match,
    #   `-E` to use regex again and `-x` to say, match the entire line, which is the same as
    #   specifying `^` and `$` at the end of the expression. `-x` is probably not strictly
    #   required here.
    #
    #   Finally, all of this is wrapped in:
    #
    #     `if [[ -n $( ... ) ]]; then`
    #
    #   This will run the `then` block if the awk -> grep -> grep pipeline prints anything
    #   as `[[ -n ... ]]` means to test if the value is non-empty.
    #
    if [[ -n $(
        awk '$1=="hyper"{print $2}' <<< "$split" \
            | grep -oE "([a-z])([a-z])\2\1" \
            | grep -vEx "([a-z])\1\1\1"
    ) ]]; then
        #echo "NOPE: hyper contains abba: '$line'"
        # don't even bother checking the 'normal' lines
        continue
    fi

    # pipe the normal lines through grep; if any match the ABBA pattern,
    # then this address does support TLS, so increment the counter
    #
    # this pipeline is exactly the same as above, except matching 'normal'
    # lines instead of 'hyper' lines.
    if [[ -n $(
        awk '$1=="normal"{print $2}' <<< "$split" \
            | grep -oE "([a-z])([a-z])\2\1" \
            | grep -vEx "([a-z])\1\1\1"
    ) ]]; then
        #echo "YEP: normal contains abba: '$line'"
        count=$(( count + 1 ))
        continue
    fi
done < "$infile"

echo $count
