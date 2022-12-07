#!/usr/bin/env bash

declare -A dir_sizes=( [/]=0 )
declare vm_cmd=
declare vm_dir=/

declare -r VOLUME_SIZE=70000000
declare -r REQUIRED_FREE_SPACE=30000000

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
        vm_cmd=
        read prompt cmd args <<< "$line"
        case "$cmd" in
            cd)
                vm_cmd=cd
                vm_cd "$args"
                ;;

            ls)
                vm_cmd=ls
                ;;

            *)
                echo "ERROR: Unexpected command '$cmd'" >&2
                exit 1
                ;;
        esac
        continue
    fi

    # process output instead
    case "$vm_cmd" in
        ls)
            read size name <<< "$line"
            if [[ $size != dir ]]; then
                add_size_to_dir "$vm_dir" "$size"
            fi
            ;;

        *)
            echo "ERROR: Unexpected command output from '$vm_cmd'" >&2
            exit 1
            ;;
    esac
done

declare -i total_used=${dir_sizes[/]}
declare -i actual_free_space=$(( VOLUME_SIZE - total_used ))
declare -i minimum_deletion=$(( REQUIRED_FREE_SPACE - actual_free_space ))
declare -i dirsize_to_delete=$total_used

for dir in "${!dir_sizes[@]}"; do
    if (( ${dir_sizes[$dir]} >= $minimum_deletion )) && (( ${dir_sizes[$dir]} < $dirsize_to_delete )); then
        dirsize_to_delete=${dir_sizes[$dir]}
    fi
done

echo $dirsize_to_delete
