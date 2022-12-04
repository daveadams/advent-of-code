#!/usr/bin/env bash

basedir=$( cd "$( dirname "${BASH_SOURCE[0]}" )"; pwd )
source "$basedir/lib/lib.sh" || { echo "ERROR: Unable to load lib.sh" >&2; exit 1; }

print_usage() {
    {
        echo "USAGE: $0 [<year> [<day> [<language>]]]"
        echo "  If no arguments are specified, all solutions below the current working"
        echo "  directory will be checked."
    } >&2
}

case "$1" in
    help|-h|--help|-help)
        print_usage
        exit 0
        ;;
esac

execdir=$( pwd )
if (( $# == 0 )); then
    reldir=${execdir/$basedir}
    IFS=/ read empty arg_year arg_day arg_lang <<< "$reldir"
elif (( $# > 0 )) && (( $# <= 3 )); then
    arg_year="$1"
    arg_day="$2"
    arg_lang="$3"
fi

run() {
    local year=$1 day=$2 lang=$3

    if [[ -z $year ]]; then
        for year in $( all_years ); do
            run_year "$year"
        done

    elif [[ -z $day ]]; then
        run_year "$year"

    elif [[ -z $lang ]]; then
        run_day "$year" "$day"

    else
        run_day_lang "$year" "$day" "$lang"
    fi
}

run_year() {
    local year=$1
    local day

    for day in $( all_days "$year" ); do
        run_day "$year" "$day"
    done
}

run_day() {
    local year=$1
    local day=$2
    local lang

    for lang in $( all_day_langs "$year" "$day" ); do
        run_day_lang "$year" "$day" "$lang"
    done
}

run_day_lang() {
    local year=$1
    local day=$2
    local lang=$3

    if ! is_valid_lang "$lang"; then
        die "Language '$lang' is not supported"
    fi

    if ! day_lang_exists "$year" "$day" "$lang"; then
        die "No solutions found at $( day_lang_dir "$year" "$day" "$lang" )"
    fi

    local sample_filename=$( sample_filename "$year" "$day" )
    local input_filename=$( input_filename "$year" "$day" )
    if [[ ! -f $sample_filename ]]; then
        die "Sample file $sample_filename was not found"
    fi
    if [[ ! -f $input_filename ]]; then
        die "Input file $input_filename was not found"
    fi

    eval "run_${lang} '$year' '$day'"
}

run_bash() {
    local year=$1
    local day=$2
    local part1=$( day_lang_dir "$year" "$day" bash )/part1.sh
    local part2=$( day_lang_dir "$year" "$day" bash )/part2.sh

    echo "Running Bash solutions for $year/$day:"
    if [[ -f $part1 ]]; then
        echo "  Part 1:"
        echo "    SAMPLE: $( bash "$part1" < "$( sample_filename "$year" "$day" )" )"
        echo "    ACTUAL: $( bash "$part1" < "$( input_filename "$year" "$day" )" )"
    else
        echo "NOTICE: Part 1 solution was not found at $part1" >&2
    fi
    if [[ -f $part2 ]]; then
        echo "  Part 2:"
        echo "    SAMPLE: $( bash "$part2" < "$( sample_filename "$year" "$day" )" )"
        echo "    ACTUAL: $( bash "$part2" < "$( input_filename "$year" "$day" )" )"
    else
        echo "NOTICE: Part 2 solution was not found at $part2" >&2
    fi
}

run_ruby() {
    local year=$1
    local day=$2
    local part1=$( day_lang_dir "$year" "$day" ruby )/part1.rb
    local part2=$( day_lang_dir "$year" "$day" ruby )/part2.rb

    echo "Running Ruby solutions for $year/$day:"
    if [[ -f $part1 ]]; then
        echo "  Part 1:"
        echo "    SAMPLE: $( ruby "$part1" < "$( sample_filename "$year" "$day" )" )"
        echo "    ACTUAL: $( ruby "$part1" < "$( input_filename "$year" "$day" )" )"
    else
        echo "NOTICE: Part 1 solution was not found at $part1" >&2
    fi
    if [[ -f $part2 ]]; then
        echo "  Part 2:"
        echo "    SAMPLE: $( ruby "$part2" < "$( sample_filename "$year" "$day" )" )"
        echo "    ACTUAL: $( ruby "$part2" < "$( input_filename "$year" "$day" )" )"
    else
        echo "NOTICE: Part 2 solution was not found at $part2" >&2
    fi
}

clean_terraform() {
    local year=$1
    local day=$2
    local rundir=$( day_lang_dir "$year" "$day" terraform )
    rm -rf "$rundir/terraform.tfstate" "$rundir/.terraform" "$rundir/.terraform.lock.hcl"
}

run_terraform() {
    local year=$1
    local day=$2
    local rundir=$( day_lang_dir "$year" "$day" terraform )

    echo "Running Terraform solutions for $year/$day:"

    clean_terraform "$year" "$day"
    cd "$rundir"

    if ! terraform init &>/dev/null; then
        die "Terraform init failed"
    fi
    if ! terraform apply -auto-approve &>/dev/null; then
        die "Terraform apply failed"
    fi
    local output=$( terraform output -json solution )

    echo "  Part 1:"
    echo "    SAMPLE: $( jq -r .part1.sample <<< "$output" )"
    echo "    ACTUAL: $( jq -r .part1.actual <<< "$output" )"
    echo "  Part 2:"
    echo "    SAMPLE: $( jq -r .part2.sample <<< "$output" )"
    echo "    ACTUAL: $( jq -r .part2.actual <<< "$output" )"

    cd "$execdir"
    clean_terraform "$year" "$day"
}

run_go() {
    local year=$1
    local day=$2
    local rundir=$( day_lang_dir "$year" "$day" go )

    echo "NOTICE: Go runs not yet supported"
}

run "$arg_year" "$arg_day" "$arg_lang"
