#!/usr/bin/env bash

basedir=$( cd "$( dirname "${BASH_SOURCE[0]}" )"; pwd )
source "$basedir/lib/lib.sh" || { echo "ERROR: Unable to load lib.sh" >&2; exit 1; }

print_usage() {
    {
        echo "USAGE: $0 <year> <day> [<language>]"
        echo "  Ensures directories are set up for the given year and day. If a language"
        echo "  is specified, a template for that language will also be created."
        echo
        echo "ALTERNATE USAGE: $0 [<language>]"
        echo "  Attempts to set up directories for today if today is a day in December."
        echo "  If a language is specified, a template for that language will be created."
    } >&2
}

case "$1" in
    help|-h|--help|-help)
        print_usage
        exit 0
        ;;
esac

if (( $# < 2 )); then
    today=$( today_maybe )
    if [[ -z $today ]]; then
        die "You must specify a date unless it's between December 1 and 25."
    fi
    IFS=/ read arg_year arg_day <<< "$today"
elif (( $# < 4 )); then
    arg_year=$1
    arg_day=$2
    shift; shift
else
    print_usage
    exit 1
fi

setup_day() {
    local year=$1
    local day=$2
    local daydir=$( day_dir $year $day )

    create_dir $daydir
    create_dir $daydir/data

    local answers=$( answers_filename $year $day )
    if [[ ! -e $answers ]]; then
        echo -n "Creating $( rel_path $answers )... "
        cat > "$answers" <<JSON
{
  "part1": {
    "sample": 0,
    "input": 0
  },
  "part2": {
    "sample": 0,
    "input": 0
  }
}
JSON
        echo OK
    fi
}

setup_bash() {
    local year=$1
    local day=$2
    local daydir=$( day_dir $1 $2 )

    create_dir "$daydir/bash"
    local part1=$daydir/bash/part1.sh
    local part2=$daydir/bash/part2.sh

    if [[ ! -e $part1 ]]; then
        echo -n "Creating $( rel_path $part1 )... "
        cat > $part1 <<BASH
#!/usr/bin/env bash

declare -i answer=0

while read line; do
    :
done

echo \$answer
BASH
        echo OK
    fi

    if [[ ! -e $part2 ]]; then
        echo -n "Creating $( rel_path $part2 )... "
        cat > $part2 <<BASH
#!/usr/bin/env bash

declare -i answer=0

while read line; do
    :
done

echo \$answer
BASH
        echo OK
    fi
}

setup_terraform() {
    local year=$1
    local day=$2
    local daydir=$( day_dir $1 $2 )

    create_dir "$daydir/terraform"
    create_dir "$daydir/terraform/solution"
    local main=$daydir/terraform/main.tf
    local solution=$daydir/terraform/solution/main.tf

    if [[ ! -e $main ]]; then
        echo -n "Creating $( rel_path $main )... "
        cat > $main <<TF
module "sample" {
  source = "./solution"
  input  = file("../data/sample.txt")
}

module "actual" {
  source = "./solution"
  input  = file("../data/input.txt")
}

output "solution" {
  value = {
    part1 = {
      sample = module.sample.solution.part1
      actual = module.actual.solution.part1
    }
    part2 = {
      sample = module.sample.solution.part2
      actual = module.actual.solution.part2
    }
  }
}
TF
        echo OK
    fi

    if [[ ! -e $solution ]]; then
        echo -n "Creating $( rel_path $solution )... "
        cat > $solution <<TF
variable "input" {
  type = string
}

locals {
  part1 = 0
  part2 = 0
}

output "solution" {
  value = {
    part1 = local.part1
    part2 = local.part2
  }
}
TF
        echo OK
    fi
}

setup_go() {
    local year=$1
    local day=$2
    local daydir=$( day_dir $1 $2 )
    create_dir "$daydir/go"
}

setup_ruby() {
    local year=$1
    local day=$2
    local daydir=$( day_dir $1 $2 )
    create_dir "$daydir/ruby"
}

if ! is_valid_year "$arg_year" || ! is_valid_day "$arg_day"; then
    die "$arg_year $arg_day is not a valid Advent of Code date"
fi

setup_day "$arg_year" "$arg_day"

if [[ -z $1 ]]; then
    exit 0
fi

arg_lang=$1
if ! is_valid_lang "$arg_lang"; then
    die "'$arg_lang' is not a supported language"
fi
eval "setup_${arg_lang} $arg_year $arg_day"

