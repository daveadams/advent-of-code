#!/usr/bin/env bash

infile="$1"

die() { echo "ERROR: $*" >&2; exit 1; }

pos=5

move() {
    local direction="$1"
    case "$direction" in
        U)
            case "$pos" in
                3) pos=1 ;;
                6) pos=2 ;;
                7) pos=3 ;;
                8) pos=4 ;;
                A) pos=6 ;;
                B) pos=7 ;;
                C) pos=8 ;;
                D) pos=B ;;
            esac
            ;;
        D)
            case "$pos" in
                1) pos=3 ;;
                2) pos=6 ;;
                3) pos=7 ;;
                4) pos=8 ;;
                6) pos=A ;;
                7) pos=B ;;
                8) pos=C ;;
                B) pos=D ;;
            esac
            ;;
        L)
            case "$pos" in
                3) pos=2 ;;
                4) pos=3 ;;
                6) pos=5 ;;
                7) pos=6 ;;
                8) pos=7 ;;
                9) pos=8 ;;
                B) pos=A ;;
                C) pos=B ;;
            esac
            ;;
        R)
            case "$pos" in
                2) pos=3 ;;
                3) pos=4 ;;
                5) pos=6 ;;
                6) pos=7 ;;
                7) pos=8 ;;
                8) pos=9 ;;
                A) pos=B ;;
                B) pos=C ;;
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
