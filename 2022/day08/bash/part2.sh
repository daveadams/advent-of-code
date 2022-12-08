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

north_view() {
    local -i row=$1 col=$2
    local -i tree=${trees[$( coord $row $col )]}
    local -i vrow view=0
    for (( vrow = row - 1; vrow >= 0; vrow-- )); do
        view+=1
        [[ ${trees[$( coord $vrow $col )]} -ge $tree ]] && break
    done
    echo $view
}

east_view() {
    local -i row=$1 col=$2
    local -i tree=${trees[$( coord $row $col )]}
    local -i vcol view=0
    for (( vcol = col + 1; vcol <= $colmax; vcol++ )); do
        view+=1
        [[ ${trees[$( coord $row $vcol )]} -ge $tree ]] && break
    done
    echo $view
}

south_view() {
    local -i row=$1 col=$2
    local -i tree=${trees[$( coord $row $col )]}
    local -i vrow view=0
    for (( vrow = row + 1; vrow <= $rowmax; vrow++ )); do
        view+=1
        [[ ${trees[$( coord $vrow $col )]} -ge $tree ]] && break
    done
    echo $view
}

west_view() {
    local -i row=$1 col=$2
    local -i tree=${trees[$( coord $row $col )]}
    local -i vcol view=0
    for (( vcol = col - 1; vcol >= 0; vcol-- )); do
        view+=1
        [[ ${trees[$( coord $row $vcol )]} -ge $tree ]] && break
    done
    echo $view
}

scenic_score() {
    local -i row=$1 col=$2
    local -i north=$( north_view $row $col )
    local -i east=$( east_view $row $col )
    local -i south=$( south_view $row $col )
    local -i west=$( west_view $row $col )
    local -i score=$(( north * east * south * west ))
    echo $score
}

declare -i tree_score max_score=0

for (( row = 0; row <= rowmax; row++ )); do
    for (( col = 0; col <= colmax; col++ )); do
        tree_score=$( scenic_score $row $col )
        (( tree_score > max_score )) && max_score=$tree_score
    done
done

echo $max_score
