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
# RIGHT, WRONG, or EQUAL
compare() {
    local sleft=$1 sright=$2

    if [[ -z $sleft ]] && [[ -z $sright ]]; then
        echo EQUAL
        return
    fi

    if [[ -z $sleft ]]; then
        echo RIGHT
        return
    fi

    if [[ -z $sright ]]; then
        echo WRONG
        return
    fi

    if is_integer "$sleft" && is_integer "$sright"; then
        local -i ileft=$sleft iright=$sright
        if (( ileft > iright )); then
            echo WRONG
        elif (( ileft < iright )); then
            echo RIGHT
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
        i+=1
        if [[ $result == EQUAL ]]; then
            continue
        fi
        echo "$result"
        return
    done

    echo EQUAL
}

declare -i index=0
declare -i answer=0

while read leftstr; do
    read rightstr
    read # empty line

    index+=1

    if [[ $( compare "$leftstr" "$rightstr" ) == RIGHT ]]; then
        answer+=$index
    fi
done

echo $answer
