#!/usr/bin/env bash

declare -i answer=0
declare -i r1min r1max r2min r2max

while IFS=,- read r1min r1max r2min r2max; do
    # # slow solution
    # for i in $( seq $r1min $r1max ); do
    #     for j in $( seq $r2min $r2max ); do
    #         if (( i == j )); then
    #             answer+=1
    #             break 2
    #         fi
    #     done
    # done
    if (( r2min >= r1min )) && (( r2min <= r1max )); then
        answer+=1
        continue
    fi
    if (( r2max >= r1min )) && (( r2max <= r1max )); then
        answer+=1
        continue
    fi
    if (( r1min >= r2min )) && (( r1min <= r2max )); then
        answer+=1
        continue
    fi
    if (( r1max >= r2min )) && (( r1max <= r2max )); then
        answer+=1
        continue
    fi
done

echo $answer
