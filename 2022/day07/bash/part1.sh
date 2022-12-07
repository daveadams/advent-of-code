#!/usr/bin/env bash

declare -A dir_sizes=( [/]=0 )
declare vm_dir=/

vm_cd() {
    local target=$1
    case "$target" in
        /)
            vm_dir=/
            ;;

        ..)
            if [[ $vm_dir != / ]]; then
                vm_dir=$( dirname "$vm_dir" )
            fi
            ;;

        *)
            if [[ $vm_dir == / ]]; then
                vm_dir=/${target}
            else
                vm_dir="$vm_dir/${target}"
            fi
            ;;
    esac
}

add_size_to_dir() {
    local dir=$1
    local -i size=$2

    if [[ -z ${dir_sizes[$vm_dir]} ]]; then
        dir_sizes[$vm_dir]=0
    fi
    dir_sizes[$dir]=$(( ${dir_sizes[$dir]} + $size ))

    if [[ $dir == / ]]; then
        return
    else
        # recurse to higher level directories
        add_size_to_dir "$( dirname "$dir" )" $size
    fi
}

while read line; do
    if [[ $line =~ ^\$ ]]; then
        read prompt cmd args <<< "$line"
        # only the 'cd' command needs to do anything here
        if [[ $cmd == cd ]]; then
            vm_cd "$args"
        fi
    else
        # process ls output instead
        read size name <<< "$line"
        if [[ $size != dir ]]; then
            add_size_to_dir "$vm_dir" "$size"
        fi
    fi
done

declare -i sum=0

for dir in "${!dir_sizes[@]}"; do
    if (( ${dir_sizes[$dir]} <= 100000 )); then
        sum+=${dir_sizes[$dir]}
    fi
done

echo $sum
