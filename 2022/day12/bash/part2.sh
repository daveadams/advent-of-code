#!/usr/bin/env bash

declare -i row=0 col=0 MAXROW MAXCOL
declare -i -A elevation
declare -i -A visited

# ord decodes the ASCII value of a character
ord() { LC_CTYPE=C printf %d "'$1"; }

# list_neighbors lists all legal neighbor coordinates from the given position
# in a format suitable to eval into an associative array
list_neighbors() {
    local coord=$1
    local -i row col
    local moves=

    IFS=, read row col <<< "$coord"

    (( row > 0 ))      && moves+="[U]=$(( row - 1 )),$col "
    (( row < MAXROW )) && moves+="[D]=$(( row + 1 )),$col "
    (( col > 0 ))      && moves+="[L]=$row,$(( col - 1 )) "
    (( col < MAXCOL )) && moves+="[R]=$row,$(( col + 1 )) "

    echo "$moves"
}

# possible_moves calculates all possible moves from the given position
possible_moves() {
    local coord=$1
    local -i current_elevation=${elevation[$coord]}
    eval "local -A neighbors=( $( list_neighbors "$coord" ) )"
    local elevation_at_neighbor

    for direction in U D L R; do
        if [[ -z ${neighbors[$direction]} ]]; then
            continue
        fi

        if [[ ${visited[${neighbors[$direction]}]} == 1 ]]; then
            continue
        fi

        elevation_at_neighbor=${elevation[${neighbors[$direction]}]}
        if (( elevation_at_neighbor < current_elevation - 1 )); then
            continue
        fi

        echo "${neighbors[$direction]}"
    done
}

while read -n1 ch; do
    if [[ -z $ch ]]; then
        row+=1
        MAXROW=$row
        MAXCOL=$col
        col=0
        continue
    fi

    case "$ch" in
        S)
            elevation[$row,$col]=$( ord a )
            visited[$row,$col]=0
            ;;

        E)
            elevation[$row,$col]=$( ord z )
            declare -r START=$row,$col
            visited[$row,$col]=1
            ;;

        *)
            elevation[$row,$col]=$( ord $ch )
            visited[$row,$col]=0
            ;;
    esac
    col+=1
done

declare -r elevation
declare -r MAXROW MAXCOL

declare -i step=0
declare -i target_altitude=$( ord a )
current="$START"

while true; do
    step+=1

    all_possible_moves=$(
        for loc in $current; do
            possible_moves "$loc"
        done |sort -u
    )

    all_valid_moves=$(
        for move in $all_possible_moves; do
            if [[ ${visited[$move]} == 1 ]]; then
                continue
            fi
            echo "$move"
        done
    )

    for move in $all_valid_moves; do
        if [[ ${elevation[$move]} == $target_altitude ]]; then
            echo $step
            exit
        fi
        visited[$move]=1
    done

    current="$all_valid_moves"
done

echo "DID NOT FIND DESTINATION?!"
exit 1
