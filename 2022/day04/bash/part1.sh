#!/usr/bin/env bash

declare -i answer=0
declare -i r1min r1max r2min r2max

while IFS=,- read r1min r1max r2min r2max; do
    if (( r1min <= r2min )) && (( r1max >= r2max )); then
        answer+=1
        continue
    fi
    if (( r2min <= r1min )) && (( r2max >= r1max )); then
        answer+=1
        continue
    fi
done

echo $answer
