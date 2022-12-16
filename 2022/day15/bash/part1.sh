#!/usr/bin/env bash

declare -i -r TARGET_ROW=${AOC_TARGET_ROW:-2000000}

declare -A sensor_to_beacon
declare -A taxi_distance
declare -i -a target_row_beacon_x_values

declare -i x y bx by dx dy
while read line; do
    read x y bx by <<< "$( tr -d 'A-Za-z=,:' <<< "$line" )"

    sensor_to_beacon[$x,$y]="$bx,$by"

    if (( x > bx )); then
        dx=$(( x - bx ))
    else
        dx=$(( bx - x ))
    fi
    if (( y > by )); then
        dy=$(( y - by ))
    else
        dy=$(( by - y ))
    fi

    taxi_distance[$x,$y]=$(( dx + dy ))
done

# calculate target row beacons
target_row_beacon_x_values=( $(
    for coord in "${sensor_to_beacon[@]}"; do
        echo "$coord"
    done \
        | grep -E ",${TARGET_ROW}\$" \
        | sort -u \
        | cut -d, -f1 \
        | cut -d= -f2 \
        | sort -n
) )

# exclusion_range prints the low and high x values excluded from containing a beacon
# in TARGET_ROW, based on the sensor at the given coordinates
exclusion_range() {
    local coord=$1
    local -i x y dx dy minx maxx
    IFS=, read x y <<< "$coord"

    if (( y > TARGET_ROW )); then
        dy=$(( y - TARGET_ROW ))
    else
        dy=$(( TARGET_ROW - y ))
    fi
    dx=$(( taxi_distance[$coord] - dy ))

    if (( dx < 0 )); then
        return
    fi
    minx=$(( x - dx ))
    maxx=$(( x + dx ))

    local -i sx
    for sx in "${target_row_beacon_x_values[@]}"; do
        if (( minx == sx )) && (( maxx == sx )); then
            # this was the only point, print nothing
            return
        fi
        if (( minx == sx )); then
            minx+=1
        elif (( maxx == sx )); then
            maxx+=-1
        elif (( sx > minx )) && (( sx < maxx )); then
            echo "ASSERTION FAILED: sensor found in the middle of an exclusion range" >&2
            exit 1
        fi
    done

    echo $minx $maxx
}

# combine_ranges prints out the low and high x values of the combined range
# given the two input ranges, or if they don't overlap, returns false
combine_ranges() {
    local -i minx1=$1 maxx1=$2 minx2=$3 maxx2=$4

    # range 1 encompasses range 2
    if (( minx1 <= minx2 )) && (( maxx1 >= maxx2 )); then
        echo $minx1 $maxx1
        return 0
    fi

    # range 2 encompasses range 1
    if (( minx2 <= minx1 )) && (( maxx2 >= maxx1 )); then
        echo $minx2 $maxx2
        return 0
    fi

    # end of range 1 overlaps beginning of range 2
    if (( minx1 < minx2 )) && (( maxx1 >= minx2 )); then
        echo $minx1 $maxx2
        return 0
    fi

    # end of range 2 overlaps beginning of range 1
    if (( minx2 < minx1 )) && (( maxx2 >= minx1 )); then
        echo $minx2 $maxx1
        return 0
    fi

    # range 1 and range 2 are directly adjacent
    if (( minx1 < minx2 )) && (( maxx1 + 1 == minx2 )); then
        echo $minx1 $maxx2
        return 0
    fi

    # range 2 and range 1 are directly adjacent
    if (( minx2 < minx1 )) && (( maxx2 + 1 == minx1 )); then
        echo $minx2 $maxx1
        return 0
    fi

    return 1
}

# simplify_ranges takes a list of ranges, one per line, and attempts to
# combine them into as few ranges as possible
simplify_ranges() {
    local ranges="$1"
    local -i minx1 maxx1 minx2 maxx2 minx maxx
    local combined

    {
        read minx1 maxx1
        while read minx2 maxx2; do
            combined=$( combine_ranges $minx1 $maxx1 $minx2 $maxx2 )
            if [[ -n $combined ]]; then
                read minx1 maxx1 <<< "$combined"
            else
                echo "$minx1 $maxx1"
                minx1=$minx2
                maxx1=$maxx2
            fi
        done
        echo "$minx1 $maxx1"
    } <<< "$ranges"
}

all_ranges=$(
    for coord in "${!sensor_to_beacon[@]}"; do
        exclusion_range "$coord"
    done |sort -n
)

declare -i old_range_lines=0 range_lines=$( wc -l <<< "$all_ranges" )

while (( old_range_lines != range_lines )); do
    all_ranges=$( simplify_ranges "$all_ranges" )
    old_range_lines=$range_lines
    range_lines=$( wc -l <<< "$all_ranges" )
done

declare -i minx maxx sum=0
while read minx maxx; do
    sum+=$(( maxx - minx + 1 ))
done <<< "$all_ranges"

echo $sum
