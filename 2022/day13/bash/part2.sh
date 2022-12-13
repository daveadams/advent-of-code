#!/usr/bin/env bash

is_integer() { [[ $1 =~ ^[0-9]+$ ]]; }
is_list() { [[ ${1:0:1} == "[" ]]; }

# parse_list breaks a list down into bash-friendly tokens of each element
parse_list() {
    local list=$1
    local -i depth=0
    local el

    while read -n1 ch; do
        case "$ch" in
            ,)
                if (( depth == 0 )); then
                    echo -n "$el "
                    el=
                else
                    el+=$ch
                fi
                ;;

            "[")
                depth+=1
                el+=$ch
                ;;

            "]")
                if (( depth == 0 )); then
                    if [[ -n $el ]]; then
                        echo -n "$el "
                    fi
                    return
                else
                    depth+=-1
                    el+=$ch
                fi
                ;;

            *)
                el+=$ch
                ;;
        esac
    done <<< "${list:1}"
}

# compare parses the left and right strings and prints
# LESSTHAN, GREATERTHAN, or EQUAL
compare() {
    local sleft=$1 sright=$2

    if [[ -z $sleft ]] && [[ -z $sright ]]; then
        echo EQUAL
        return
    fi

    if [[ -z $sleft ]]; then
        echo LESSTHAN
        return
    fi

    if [[ -z $sright ]]; then
        echo GREATERTHAN
        return
    fi

    if is_integer "$sleft" && is_integer "$sright"; then
        local -i ileft=$sleft iright=$sright
        if (( ileft < iright )); then
            echo LESSTHAN
        elif (( ileft > iright )); then
            echo GREATERTHAN
        elif (( ileft == iright )); then
            echo EQUAL
        fi
        return
    fi

    if is_list "$sleft" && is_integer "$sright"; then
        sright="[$sright]"
    fi

    if is_integer "$sleft" && is_list "$sright"; then
        sleft="[$sleft]"
    fi

    # both should be lists at this point
    local -a left=( $( parse_list "$sleft" ) )
    local -a right=( $( parse_list "$sright" ) )

    local result
    local -i i=0
    while [[ $i -le ${#left[@]} ]] && [[ $i -le ${#right[@]} ]]; do
        result=$( compare "${left[$i]}" "${right[$i]}" )
        if [[ $result == EQUAL ]]; then
            i+=1
            continue
        fi
        echo "$result"
        return
    done

    echo EQUAL
}

declare -a packets
declare -i packet_count=0

while read line; do
    [[ -z $line ]] && continue
    packets+=( "$line" )
    packet_count+=1
done

DIV1="[[2]]"
DIV2="[[6]]"
declare -i decoder1=1 decoder2=2 i

for (( i = 0; i < packet_count; i++ )); do
    if [[ $( compare "$DIV1" "${packets[$i]}" ) == GREATERTHAN ]]; then
        decoder1+=1
    fi
    if [[ $( compare "$DIV2" "${packets[$i]}" ) == GREATERTHAN ]]; then
        decoder2+=1
    fi
done

echo $(( decoder1 * decoder2 ))
