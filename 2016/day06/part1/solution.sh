#!/usr/bin/env bash

infile="$1"
message=""

cols=$( echo -n "$( head -n 1 "$infile" )" |wc -c )

for col in $( seq 1 $cols ); do
    message+=$( cut -c $col "$infile" |sort |uniq -c |sort -rn |head -n 1 |awk '{print $2}' )
done
echo "$message"
