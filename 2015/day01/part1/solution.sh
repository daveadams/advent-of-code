#!/usr/bin/env bash

floor=0

while read -n 1 CH; do
    case "$CH" in
        "(") (( floor++ )) ;;
        ")") (( floor-- )) ;;
        "") ;;
        *) echo "ERROR: Got unexpected character '$CH'" >&2; exit 1; ;;
    esac
done

echo "$floor"
