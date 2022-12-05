#!/usr/bin/env bash

# each stack is represented by a string with the "top" of each stack being
# the first letter of the string, and the "bottom" being the last letter.
declare -a stacks

# variable crane stores the value of the box currently held by the crane
# this variable is used and managed by the pickup and setdown functions and
# should not be set directly
declare crane

require_valid_stack() {
    local -i stackid=$1
    if (( stackid < 1 )); then
        echo "ERROR: Invalid stack ID '$1'" >&2
        exit 1
    fi
}

# pickup (aka pop) takes the item off the top of the specified stack and stores
# it in the 'crane' variable. If the crane is already in use or if the stack
# has no items, this function exits with an error.
pickup() {
    if [[ -n $crane ]]; then
        echo "ERROR: Operator Failure: The crane is already occupied!" >&2
        exit 1
    fi

    require_valid_stack "$1"
    local -i stackid=$1

    if [[ -z ${stacks[$stackid]} ]]; then
        echo "ERROR: Operator Failure: There are no boxes in stack $stackid!" >&2
        exit 1
    fi

    # the "top" of the stack is the front of the string
    crane=${stacks[$stackid]:0:1}
    stacks[$stackid]=${stacks[$stackid]:1}
}

# setdown (aka push) puts the item on the crane onto the top of the specified
# stack. If the crane is empty, this function exits with an error.
setdown() {
    if [[ -z $crane ]]; then
        echo "ERROR: Operator Failure: The crane is empty!" >&2
        exit 1
    fi

    require_valid_stack "$1"
    local -i stackid=$1

    stacks[$stackid]=${crane}${stacks[$stackid]}
    crane=
}

# peek prints the value of the item on top of the given stack
peek() {
    require_valid_stack "$1"
    local -i stackid=$1
    echo -n ${stacks[$stackid]:0:1}
}

# print_message prints the message spelled out by the top of all stacks
print_message() {
    local -i i
    for i in $( seq 1 ${#stacks[*]} ); do
        peek $i
    done
    echo
}

# print_stacks is useful for debugging the stacks
print_stacks() {
    local -i i
    for i in $( seq 1 ${#stacks[*]} ); do
        echo STACK $i: ${stacks[$i]}
    done
}

# first parse the structure of the existing stacks
# set IFS='' to prevent read from eating opening spaces
while IFS='' read line; do
    if [[ ${line:0:3} == " 1 " ]]; then
        # this is the stack label line, which we can skip
        break
    fi

    rest=$line
    declare -i stackid=0
    # parse line in four character chunks
    while [[ -n $rest ]]; do
        stackid+=1
        # only the first three characters matter
        chunk=${rest:0:3}
        rest=${rest:4}
        if [[ $chunk == "   " ]]; then
            continue
        fi
        value=${chunk:1:1}

        # now shift the value onto the bottom of the stack we are reading
        stacks[$stackid]=${stacks[$stackid]}${value}
    done
done

# then there should be an empty line
read line
if [[ -n $line ]]; then
    echo "ERROR: Unexpected data format" >&2
    exit 1
fi

# now read and follow the instructions
declare -i count from_stack to_stack
while read junk1 count junk2 from_stack junk3 to_stack; do
    for i in $( seq 1 $count ); do
        pickup "$from_stack"
        setdown "$to_stack"
    done
done

# and finally calculate the message
print_message
