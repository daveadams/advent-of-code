#!/usr/bin/env bash

good=0
bad=0
total=0

while IFS=, read testdata expected; do
    actual=$( ./solution.sh <<< "$testdata" )
    (( total++ ))
    if [[ $expected == $actual ]]; then
        (( good++ ))
        result=OK
    else
        (( bad++ ))
        result=FAIL
    fi
    echo "input: '$testdata'; expected: '$expected'; actual: '$actual'; result: $result"
done < tests.csv
echo
echo "$good/$total correct tests"

if (( bad > 0 )); then
    echo
    echo "FAILURE: $bad fails"
    exit 1
fi
