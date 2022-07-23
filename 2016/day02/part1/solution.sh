#!/usr/bin/env bash

infile="$1"

die() { echo "ERROR: $*" >&2; exit 1; }

pos=5

move() {
    local direction="$1"
    case "$direction" in
        U)
            case "$pos" in
                4) pos=1 ;;
                5) pos=2 ;;
                6) pos=3 ;;
                7) pos=4 ;;
                8) pos=5 ;;
                9) pos=6 ;;
            esac
            ;;
        D)
            case "$pos" in
                1) pos=4 ;;
                2) pos=5 ;;
                3) pos=6 ;;
                4) pos=7 ;;
                5) pos=8 ;;
                6) pos=9 ;;
            esac
            ;;
        L)
            case "$pos" in
                2) pos=1 ;;
                3) pos=2 ;;
                5) pos=4 ;;
                6) pos=5 ;;
                8) pos=7 ;;
                9) pos=8 ;;
            esac
            ;;
        R)
            case "$pos" in
                1) pos=2 ;;
                2) pos=3 ;;
                4) pos=5 ;;
                5) pos=6 ;;
                7) pos=8 ;;
                8) pos=9 ;;
            esac
            ;;
    esac
}

while read line; do
    while read -n 1 ch; do
        move $ch
    done <<< "$line"
    echo -n $pos
done < "$infile"
echo
