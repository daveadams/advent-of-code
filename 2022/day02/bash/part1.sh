#!/usr/bin/env bash

declare -A lookup=(
    [A]=rock
    [B]=paper
    [C]=scissors
    [X]=rock
    [Y]=paper
    [Z]=scissors
)

wins() {
    [[ $1 == rock ]] && [[ $2 == scissors ]] && return 0
    [[ $1 == paper ]] && [[ $2 == rock ]] && return 0
    [[ $1 == scissors ]] && [[ $2 == paper ]] && return 0
    return 1
}

declare -i score=0
while read opp_raw self_raw; do
    opp=${lookup[$opp_raw]}
    self=${lookup[$self_raw]}

    if [[ -z $opp ]] || [[ -z $self ]]; then
        echo "ERROR: Bad Data"
        exit 1
    fi

    # first add the value of the shape I selected
    case "$self" in
        rock) score+=1 ;;
        paper) score+=2 ;;
        scissors) score+=3 ;;
    esac

    # then determine the outcome
    if [[ $opp == $self ]]; then
        # draw!
        score+=3
    elif wins $self $opp; then
        # win!
        score+=6
    fi
    # lose = 0pts
done

echo $score
