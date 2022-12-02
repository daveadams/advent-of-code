#!/usr/bin/env bash

declare -A lookup_move=( [A]=rock [B]=paper [C]=scissors )
declare -A lookup_outcome=( [X]=lose [Y]=draw [Z]=win )
declare -A lookup_winner=( [rock]=paper [paper]=scissors [scissors]=rock )
declare -A lookup_loser=( [rock]=scissors [paper]=rock [scissors]=paper )
declare -A move_score=( [rock]=1 [paper]=2 [scissors]=3 )
declare -A outcome_score=( [lose]=0 [draw]=3 [win]=6 )

declare -i score=0
while read raw_opp_move raw_outcome; do
    opp_move=${lookup_move[$raw_opp_move]}
    outcome=${lookup_outcome[$raw_outcome]}
    my_move=

    case "$outcome" in
        lose) my_move=${lookup_loser[$opp_move]} ;;
        draw) my_move=$opp_move ;;
        win)  my_move=${lookup_winner[$opp_move]} ;;
    esac

    score+=${move_score[$my_move]}
    score+=${outcome_score[$outcome]}
done

echo $score
