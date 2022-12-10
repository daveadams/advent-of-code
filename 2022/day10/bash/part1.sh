#!/usr/bin/env bash

declare -i cycle signal=0 x=1 readyat=1
declare opcode arg
declare -i pending_add

for (( cycle = 1; cycle <= 220; cycle++ )); do
    if (( ( cycle % 40 ) == 20 )); then
        #echo -n "CYCLE $cycle: X=$x ; signal = $signal + ( $x * $cycle ) = $signal + $(( x * cycle )) = "
        signal=$(( signal + ( x * cycle ) ))
        #echo "$signal"
    fi

    # are we ready to do new work?
    if (( readyat <= cycle )); then
        read opcode arg
        #echo "CYCLE $cycle OP: '$opcode' '$arg'"
        case "$opcode" in
            noop)
                readyat=$(( cycle + 1 ))
                lastop=noop
                ;;

            addx)
                readyat=$(( cycle + 2 ))
                lastop=addx
                pending_add=$arg
                ;;
        esac
    fi

    # finish addx if it's pending
    if (( readyat == ( cycle + 1 ) )) && [[ $lastop == addx ]]; then
        #echo -n "END OF CYCLE $cycle: finishing 'addx $pending_add' "
        x=$(( x + pending_add ))
        #echo "X=$x"
    fi
done

echo $signal
