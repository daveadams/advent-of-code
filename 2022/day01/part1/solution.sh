#!/usr/bin/env bash

# declare -i sets a variable to be of integer type
declare -i snack elf=0 max=0

# $elves is an array of integers
declare -i -a elves

while read snack; do
    if (( snack == 0 )); then
        if (( elves[$elf] > max )); then
            max=${elves[elf]}
        fi
        elf+=1
        continue
    fi
    elves[elf]+=$snack
done
if (( elves[$elf] > max )); then
    max=${elves[elf]}
fi

echo $max
