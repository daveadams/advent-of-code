#!/usr/bin/env bash

door_id="$1"

# actually computing the hashes is outsourced to a go program (md5-per-line.go)
# printing an md5 hash of each input line it receives to avoid the overhead of
# starting a program 20+ million times for each hash evaluation

# shut off stderr to avoid ugly "signal: broken pipe" error message
exec 2>&-

{
    # this is an ugly way to generate hash values, but bash gets slow when
    # you make the `in` clause really big, and something here starts displaying
    # numbers in scientific notation after 999999 so this terrible hack makes
    # it work beyond one million
    for n in $( seq 1 999999 ); do
        echo "$door_id$n"
    done
    for m in $( seq 1 999999 ); do
        for n in $( seq 0 999999 ); do
            printf "%s%d%06d\n" $door_id $m $n
        done
    done
} | go run md5-per-line.go | grep --line-buffered ^00000 | head -n 8 |cut -c6 \
    | while read line; do echo -n $line; done
# the pipeline above goes like this:
# * send each line to the `go run md5-per-line.go` process, which will print the md5 sum
#   of each line
# * pipe that through `grep ^00000` to match only the lines that begin with five zeroes
#   (the `--line-buffered` option forces grep to print lines as they match instead of
#   buffering input and output)
# * `head -n 8` prints the first eight lines that grep matches, and then shuts down
#   (this is the source of the "broken pipe" errors mentioned above)
# * `cut -c6` prints just the sixth character of the line
# * `while read line; do echo -n $line; done` takes each line given, and prints it
#   with no trailing line break, so the result is all eight characters in a row
# Finally we run `echo` to add the missing line break.
echo
