#!/usr/bin/env bash

die() { echo "ERROR: $*" >&2; exit 1; }

# store the number of items each monkey inspects
declare -i -a monkey_activity

# store the current items each monkey holds as a space-separated string
declare -a monkey_items

# store the un-evaled bash operation string version of the operation
# each monkey has on each item
declare -a monkey_operation

# store the divisor each monkey will use to test which other monkey to
# throw the item to
declare -i -a monkey_divisor

# target monkeys to throw to if the test is true or false
declare -i -a monkey_target_true
declare -i -a monkey_target_false

declare -i monkey
declare -i monkey_count=0

while read line; do
    # Monkey 0:
    #[[ $line =~ "^Monkey [0-9]:$" ]] || die "Unexpected monkey line '$line'"
    monkey=$( tr -d : <<< "$line" |cut -d' ' -f2 )
    monkey_activity[$monkey]=0

    # Starting items: 79, 98
    read line || die "Ran out of input too soon"
    #[[ $line =~ "^Starting items: [0-9][0-9](, [0-9]+)+$" ]] || die "Unexpected starting items line '$line'"
    monkey_items[$monkey]=$( cut -d' ' -f3- <<< "$line" |tr -d , )

    # Operation: new = old * 19
    read line || die "Ran out of input too soon"
    #[[ $line =~ "^Operation: new = " ]] || die "Unexpected operation line '$line'"
    formula=$( cut -d' ' -f4- <<< "$line" )
    monkey_operation[$monkey]="\$(( $( sed s/old/worry/g <<< "$formula" ) ))"

    # Test: divisible by 23
    read line || die "Ran out of input too soon"
    #[[ $line =~ "^Test: divisible by [0-9]+$" ]] || die "Unexpected test line '$line'"
    monkey_divisor[$monkey]=$( cut -d' ' -f4 <<< "$line" )

    #   If true: throw to monkey 2
    read line || die "Ran out of input too soon"
    #[[ $line =~ "^If true: throw to monkey [0-9]+$" ]] || die "Unexpected if true line '$line'"
    monkey_target_true[$monkey]=$( cut -d' ' -f6 <<< "$line" )

    #   If false: throw to monkey 3
    read line || die "Ran out of input too soon"
    #[[ $line =~ "^If false: throw to monkey [0-9]+$" ]] || die "Unexpected if false line '$line'"
    monkey_target_false[$monkey]=$( cut -d' ' -f6 <<< "$line" )

    monkey_count+=1

    # read an empty line
    read
done

declare -i ROUNDS=20 round

print_state() {
    local -i i
    echo Round $round
    for (( i = 0; i < monkey_count; i++ )); do
        echo "  MONKEY $i: ${monkey_items[$i]}"
    done
}

for (( round = 1; round <= ROUNDS; round++ )); do
    for (( monkey = 0; monkey < monkey_count; monkey++ )); do
        for worry in ${monkey_items[$monkey]}; do
            monkey_activity[$monkey]+=1
            eval "worry=${monkey_operation[$monkey]}"
            worry=$(( worry / 3 ))
            divisor=${monkey_divisor[$monkey]}
            if (( worry % divisor == 0 )); then
                monkey_items[${monkey_target_true[$monkey]}]+=" $worry"
            else
                monkey_items[${monkey_target_false[$monkey]}]+=" $worry"
            fi
        done
        monkey_items[$monkey]=
    done
    #(( round % 5 == 0 )) && print_state
done

top_two=( $( echo ${monkey_activity[@]} |tr ' ' '\n' |sort -n |tail -n 2 ) )
echo $(( top_two[0] * top_two[1] ))
