#!/usr/bin/env bash

floor=0
pos=0

while read -n 1 CH; do
    case "$CH" in
        "(") (( floor++ )); (( pos++ )) ;;
        ")") (( floor-- )); (( pos++ )) ;;
        "") ;;
        *) echo "ERROR: Got unexpected character '$CH'" >&2; exit 1; ;;
    esac
    if (( floor == -1 )); then
        echo "$pos"
        exit 0
    fi
done

echo "ERROR: Santa never found the basement" >&2
exit 1
