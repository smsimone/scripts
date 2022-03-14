#!/bin/bash

function command_exists() {
    if [[ -z "$1" ]]; then
        _print_error "ERROR: Missing #1 parameter"
        echo false
        return false
    fi

    if [[ ! -x "$(command -v "$1")" ]]; then
        echo false
        return false
    fi

    echo true
    return true
}

if [[ "$(command_exists greadlink)" ]]; then
    ### Loads all the scripts contained in this folder
    DIR=$(greadlink -f "$0" | sed -e "s/\/load.sh//g")

    to_load=($(find "$DIR" -name "*.sh"))
    for script in $to_load; do
        if [[ "$script" != *"load"* ]]; then
            source "$script"
        fi
    done
fi

#export PATH="$PATH:$(pwd)"
