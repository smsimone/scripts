#!/bin/bash

function command_exists() {
    if [[ -z "$1" ]]; then
        _print_error "ERROR: Missing #1 parameter"
        return 1
    fi

    if [[ ! -x "$(command -v "$1")" ]]; then
        return 1
    fi

    return 0
}

command_exists greadlink

if [[ $? -eq 0 ]]; then
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
git remote update >/dev/null 2>&1
is_behind=$(git status -uno | grep "Your branch is behind")
if [[ -n "$is_behind" ]]; then
    git pull >/dev/null 2>&1
    echo "Scripts updated, please reload your shell"
fi
