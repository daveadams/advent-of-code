#!/usr/bin/env bash

declare -i cycle x=1 readyat=1 hpos
declare opcode arg
declare -i pending_add

for (( cycle = 1; cycle <= 240; cycle++ )); do
    # are we ready to do new work?
    if (( readyat <= cycle )); then
        read opcode arg
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

    # draw pixel or not?
    hpos=$(( ( cycle - 1 ) % 40 ))
    if (( hpos >= ( x - 1 ) )) && (( hpos <= ( x + 1 ) )); then
        echo -n "#"
    else
        echo -n "."
    fi

    # end of row
    if (( hpos == 39 )); then
        echo
    fi

    # finish addx if it's pending
    if (( readyat == ( cycle + 1 ) )) && [[ $lastop == addx ]]; then
        x=$(( x + pending_add ))
    fi
done

