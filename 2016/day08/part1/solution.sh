#!/usr/bin/env bash

infile="$1"

initrows=6
initcols=50

if [[ $infile == test-data ]]; then
    initrows=3
    initcols=7
fi

maxrow=$(( initrows - 1 ))
maxcol=$(( initcols - 1 ))

declare -a display_rows

# INITIALIZE
for r in $( seq 0 $maxrow ); do
    row=""
    for c in $( seq 0 $maxcol ); do
        row+=" "
    done
    display_rows[$r]="$row"
done

print_display() {
    local r
    for r in $( seq 0 $maxrow ); do
        echo "${display_rows[$r]}"
    done
}

count_lights_on() {
    local r c
    local count=0
    for r in $( seq 0 $maxrow ); do
        for c in $( seq 0 $maxcol ); do
            if [[ ${display_rows[$r]:$c:1} == "#" ]]; then
                count=$(( count + 1 ))
            fi
        done
    done
    echo "$count"
}

rect() {
    local cols="$1"
    local rows="$2"
    local r c
    local boxline=""

    for c in $( seq 0 $(( cols - 1 )) ); do
        boxline+="#"
    done

    for r in $( seq 0 $(( rows - 1 )) ); do
        display_rows[$r]="$boxline${display_rows[$r]:$cols}"
    done
}

rotate_row() {
    local row="$1"
    local n="$2"
    local c
    local -a new_row
    local newcol

    for c in $( seq 0 $maxcol ); do
        newcol=$(( ( c + n ) % initcols ))
        new_row[$newcol]=${display_rows[$row]:$c:1}
    done

    display_rows[$row]=""

    for c in $( seq 0 $maxcol ); do
        display_rows[$row]+=${new_row[$c]}
    done
}

rotate_column() {
    local col="$1"
    local n="$2"
    local r
    local -a orig_column
    local -a new_column
    local newrow

    for r in $( seq 0 $maxrow ); do
        orig_column[$r]="${display_rows[$r]:$col:1}"
    done

    for r in $( seq 0 $maxrow ); do
        newrow=$(( ( r + n ) % initrows ))
        new_column[$newrow]="${orig_column[$r]}"
    done

    for r in $( seq 0 $maxrow ); do
        if [[ $col == 0 ]]; then
            display_rows[$r]="${new_column[$r]}${display_rows[$r]:1}"
        elif [[ $col == $maxcol ]]; then
            display_rows[$r]="${display_rows[$r]:0:$col}${new_column[$r]}"
        else
            display_rows[$r]="${display_rows[$r]:0:$col}${new_column[$r]}${display_rows[$r]:$(( col + 1 ))}"
        fi
    done
}

while read line; do
    argv=( $line )
    case "${argv[0]}" in
        rect)
            cols=$( cut -dx -f1 <<< "${argv[1]}" )
            rows=$( cut -dx -f2 <<< "${argv[1]}" )
            rect $cols $rows
            ;;

        rotate)
            rtype="${argv[1]}"
            id=$( cut -d= -f2 <<< "${argv[2]}" )
            n="${argv[4]}"
            if [[ $rtype == column ]]; then
                rotate_column $id $n
            elif [[ $rtype == row ]]; then
                rotate_row $id $n
            fi
            ;;
    esac
done < "$infile"

#print_display
count_lights_on
