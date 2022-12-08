#!/usr/bin/env bash

# normalize row and col coordinates to use leading zeroes
coord() { printf "%02d%02d" "$1" "$2"; }

declare -A trees
declare -i row=0 col=0
while read line; do
    [[ -z $line ]] && continue
    col=0
    while read -n1 ch; do
        [[ -z $ch ]] && continue
        trees[$( coord $row $col )]=$ch
        col+=1
    done <<< "$line"
    row+=1
done
declare -i -r rowmax=$(( row - 1 ))
declare -i -r colmax=$(( col - 1 ))

declare -A visible
# initialize visibility map
for (( row = 0; row <= rowmax; row++ )); do
    for (( col = 0; col <= colmax; col++ )); do
        loc=$( coord $row $col )
        # outside edges are always visible
        if (( row == 0 )) || (( row == rowmax )) || (( col == 0 )) || (( col == colmax )); then
            visible[$loc]=1
        else
            visible[$loc]=0
        fi
    done
done

declare -i tallest=0
declare -i tree

# traverse trees left to right
for (( row = 0; row <= rowmax; row++ )); do
    tallest=${trees[$( coord $row 0 )]}
    for (( col = 0; col <= colmax; col++ )); do
        loc=$( coord $row $col )
        tree=${trees[$loc]}
        if (( tree > tallest )); then
            tallest=${trees[$loc]}
            visible[$loc]=1
        fi
        (( tallest == 9 )) && break # nothing can be taller
    done
done

# traverse trees right to left
for (( row = 0; row <= rowmax; row++ )); do
    tallest=${trees[$( coord $row $colmax )]}
    for (( col = $colmax; col >= 0 ; col-- )); do
        loc=$( coord $row $col )
        tree=${trees[$loc]}
        if (( tree > tallest )); then
            tallest=${trees[$loc]}
            visible[$loc]=1
        fi
        (( tallest == 9 )) && break # nothing can be taller
    done
done

# traverse trees top to bottom
for (( col = 0; col <= colmax; col++ )); do
    tallest=${trees[$( coord 0 $col )]}
    for (( row = 0; row <= rowmax; row++ )); do
        loc=$( coord $row $col )
        tree=${trees[$loc]}
        if (( tree > tallest )); then
            tallest=${trees[$loc]}
            visible[$loc]=1
        fi
        (( tallest == 9 )) && break # nothing can be taller
    done
done

# traverse trees bottom to top
for (( col = 0; col <= colmax; col++ )); do
    tallest=${trees[$( coord $rowmax $col )]}
    for (( row = $rowmax; row >= 0; row-- )); do
        loc=$( coord $row $col )
        tree=${trees[$loc]}
        if (( tree > tallest )); then
            tallest=${trees[$loc]}
            visible[$loc]=1
        fi
        (( tallest == 9 )) && break # nothing can be taller
    done
done

# count visible trees
declare -i count=0
for (( row = 0; row <= rowmax; row++ )); do
    for (( col = 0; col <= colmax; col++ )); do
        count+=${visible[$( coord $row $col )]}
    done
done

echo $count
