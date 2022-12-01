#!/usr/bin/env bash

declare -i line elf

{
    while read line; do
        if (( line == 0 )); then
            echo $elf
            elf=0
            continue
        fi
        elf+=$line
    done
    (( elf > 0 )) && echo $elf
} \
    | sort -n \
    | tail -n 3 \
    | awk '{sum+=$1}END{print sum}'
