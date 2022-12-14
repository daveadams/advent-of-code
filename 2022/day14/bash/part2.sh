#!/usr/bin/env bash

declare -A grid
declare -i MAXDEPTH=0
declare -i MINX=500 MAXX=0

declare -r ORIGIN_X=500 ORIGIN_Y=0
declare -r ROCK="#"
declare -r SAND=o
declare -r VOID=.

record_line() {
    local from_xy=$1
    local to_xy=$2
    local -i from_x from_y to_x to_y

    IFS=, read from_x from_y <<< "$from_xy"
    IFS=, read to_x to_y <<< "$to_xy"

    # only one of x or y will change for each line
    if (( from_x != to_x )); then
        # y will stay the same
        local -r y=$from_y

        local xseq
        if (( from_x < to_x )); then
            xseq=$( seq $from_x $to_x )
        else
            xseq=$( seq $to_x $from_x )
        fi

        local -i x
        for x in $xseq; do
            grid[$x,$y]=$ROCK
        done

    elif (( from_y != to_y )); then
        # x will stay the same
        local -r x=$from_x

        local yseq
        if (( from_y < to_y )); then
            yseq=$( seq $from_y $to_y )
        else
            yseq=$( seq $to_y $from_y )
        fi

        local -i y
        for y in $yseq; do
            grid[$x,$y]=$ROCK
        done
    fi

    # update boundaries
    (( from_y > MAXDEPTH )) && MAXDEPTH=$from_y
    (( to_y   > MAXDEPTH )) && MAXDEPTH=$to_y
    (( from_x > MAXX     )) && MAXX=$from_x
    (( to_x   > MAXX     )) && MAXX=$to_x
    (( from_x < MINX     )) && MINX=$from_x
    (( to_x   < MINX     )) && MINX=$to_x
}

draw_state() {
    local -i x y

    for (( y = 0; y <= MAXDEPTH+1; y++ )); do
        for (( x = MINX-1; x <= MAXX+1; x++ )); do
            if [[ -z "${grid[$x,$y]}" ]]; then
                echo -n $VOID
            else
                echo -n "${grid[$x,$y]}"
            fi
        done
        echo
    done

    # draw rock floor
    for (( x = MINX-1; x <= MAXX+1; x++ )); do
        echo -n "#"
    done
    echo
}

is_occupied() {
    local -i x=$1 y=$2
    if [[ -n "${grid[$x,$y]}" ]]; then
        return 0
    fi
    if (( y == MAXDEPTH + 2 )); then
        return 0
    fi
    return 1
}

drop_sand() {
    local -i x=$ORIGIN_X y=$ORIGIN_Y

    if is_occupied $x $y; then
        return 1
    fi

    while (( y <= $MAXDEPTH + 2 )); do
        if ! is_occupied $x $(( y + 1 )); then
            y+=1
            continue
        fi

        if ! is_occupied $(( x - 1 )) $(( y + 1 )); then
            x+=-1
            y+=1
            continue
        fi

        if ! is_occupied $(( x + 1 )) $(( y + 1 )); then
            x+=1
            y+=1
            continue
        fi

        # nowhere to go, so stop here
        grid[$x,$y]=$SAND

        # adjust MINX MAXX
        (( x < MINX )) && MINX=$x
        (( x > MAXX )) && MAXX=$x
        return 0
    done

    # should never reach this point
    echo "SCRIPT FAILURE: Assertion failed" >&2
    exit 1
}

while read line; do
    from=
    to=
    while read coord; do
        from="$to"
        to="$coord"
        [[ -z $from ]] && continue
        record_line "$from" "$to"
    done < <( sed 's/ -> /\n/g' <<< "$line" )
done

# actually do the work
declare -i grains=0
while drop_sand; do
    grains+=1
done
echo $grains
