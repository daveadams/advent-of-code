#!/usr/bin/env bash

infile="$1"

debug() { [[ -n $DEBUG ]] && echo "$@"; }

declare -A bots inputs outputs output_values bot_inputs

while read -a tokens; do
    case "${tokens[0]}" in
        value)
            input_id="${tokens[1]}"
            bot_id="${tokens[5]}"
            inputs[$input_id]=$bot_id
            ;;
        bot)
            bot_id="${tokens[1]}"
            low_type="${tokens[5]}"
            low_id="${tokens[6]}"
            high_type="${tokens[10]}"
            high_id="${tokens[11]}"

            if [[ $low_type == output ]]; then
                outputs[$low_id]=0
                output_values[$low_id]=0
            fi
            if [[ $high_type == output ]]; then
                outputs[$high_id]=0
                output_values[$high_id]=0
            fi
            bots[$bot_id]="$low_type $low_id $high_type $high_id"
            bot_inputs[$bot_id]=""
            bot_done[$bot_id]=0
            ;;
    esac
done < "$infile"

# process inputs: push each input value to the appropriate bot
for value in "${!inputs[@]}"; do
    bot_id="${inputs[$value]}"
    bot_inputs[${bot_id}]+=" $value"
done

# process bots until they are done
while true; do
    undone=0
    for bot_id in "${!bots[@]}"; do
        if [[ ${bot_done[${bot_id}]} == 1 ]]; then
            continue
        fi
        read x y <<< "${bot_inputs[$bot_id]}"
        if [[ -n $x ]] && [[ -n $y ]]; then
            read low_type low_id high_type high_id <<< "${bots[$bot_id]}"
            debug "PROCESSING BOT $bot_id ($x, $y): $low_type $low_id $high_type $high_id"
            low="$x"
            high="$y"
            if (( $x > $y )); then
                low="$y"
                high="$x"
            fi
            if [[ $low_type == bot ]]; then
                bot_inputs[${low_id}]+=" $low"
            elif [[ $low_type == output ]]; then
                outputs[${low_id}]=$(( ${outputs[${low_id}]} + 1 ))
                output_values[${low_id}]="$low"
            fi
            if [[ $high_type == bot ]]; then
                bot_inputs[${high_id}]+=" $high"
            elif [[ $high_type == output ]]; then
                outputs[${high_id}]=$(( ${outputs[${high_id}]} + 1 ))
                output_values[${high_id}]="$high"
            fi
            # normalize inputs
            bot_inputs[${bot_id}]="$low $high"
            bot_done[${bot_id}]=1
        else
            debug "DEBUG: incomplete bot $bot_id ('$x', '$y')"
            undone=$(( undone + 1 ))
        fi
    done
    if [[ $undone == 0 ]]; then
        debug "DEBUG: ALL DONE"
        break
    fi
done

# multiply the output values of outputs 0, 1, and 2
echo $(( ${output_values[0]} * ${output_values[1]} * ${output_values[2]} ))
