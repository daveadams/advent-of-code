die() { echo "ERROR: $*" >&2; exit 1; }

today_maybe() {
    local y m d
    read y m d <<< "$( date "+%Y %m %d" )"
    if [[ $m == 12 ]] && (( d <= 25 )); then
        echo $y/day$d
    fi
}

sample_filename() { echo "$( data_dir $1 $2 )/sample.txt"; }
input_filename() { echo "$( data_dir $1 $2 )/input.txt"; }
answers_filename() { echo "$( data_dir $1 $2 )/answers.json"; }
year_dir() { echo "$basedir/$1"; }
day_dir() { echo "$basedir/$1/$2"; }
day_lang_dir() { echo "$basedir/$1/$2/$3"; }
data_dir() { echo "$basedir/$1/$2/data"; }

is_valid_year() { [[ $1 =~ ^2[0-9]{3}$ ]]; }
is_valid_day() { [[ $1 =~ ^day([0-1][0-9]|2[0-5])$ ]]; }
is_valid_lang() {
    case "$1" in
        bash|ruby|terraform|go) return 0 ;;
    esac
    return 1
}

year_exists() { [[ -d "$basedir/$1" ]]; }
day_exists() { [[ -d "$basedir/$1/$2" ]]; }
day_lang_exists() { [[ -d "$basedir/$1/$2/$3" ]]; }

all_years() { ls -p "$basedir" |grep -E '^2[0-9]{3}/$' |sed 's,/$,,'; }
all_days() {
    local year=$1
    year_exists "$year" || return 1
    ls -p "$basedir/$year" |grep -E '^day[0-2][0-9]/$' |sed 's,/$,,'
}
all_day_langs() {
    local year=$1
    local day=$2
    day_exists "$year" "$day" || return 1
    ls -p "$basedir/$year/$day" |grep -E '^(bash|ruby|terraform|go)/$' |sed 's,/$,,'
}

rel_path() { echo "${1/$basedir}" |sed s,^/,,; }

create_dir() {
    local newdir=$1
    if [[ ! -d $newdir ]]; then
        echo -n "Creating $( rel_path $newdir )... "
        mkdir -p "$newdir"
        echo OK
    fi
}

part_inputs() {
    local year=$1
    local day=$2
    local part=$3

    if [[ $part != 1 ]] && [[ $part != 2 ]]; then
        die "Script Error: Invalid Part"
    fi

    local answers_file=$( answers_filename $year $day )
    if [[ ! -f $answers_file ]]; then
        die "Unable to read $( rel_path $answers_file )"
    fi

    jq -r '.part'"${part}"'|keys[]' "$answers_file"
}
