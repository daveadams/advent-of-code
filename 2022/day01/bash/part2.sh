#!/usr/bin/env bash

declare -i snack elf
{
    while read snack; do
        if (( snack == 0 )); then
            echo $elf
            elf=0
            continue
        fi
        elf+=$snack
    done
    (( elf > 0 )) && echo $elf
} \
    | sort -n \
    | tail -n 3 \
    | awk '{sum+=$1}END{print sum}'
