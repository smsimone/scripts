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

function reset_scripts() {
    if [ -f 'config.json' ]; then
        rm 'config.json'
        echo "Scripts resetted"
    else
        echo "No config.json found"
    fi
}

sourced=$(cat "$HOME/.zshrc" | grep "load.sh")

if [[ -n "$sourced" ]]; then
    current_path=$(echo "$sourced" | awk '{print $2}' | sed 's/\"//g' | sed 's/\/load.sh//g')
    expanded_path="${current_path/#\$HOME/$HOME}"

    (
        cd "$expanded_path"
        if [ -f 'config.json' ]; then
            # The config file exists so we will load it
            to_load=($(jq '.files' config.json | jq '.[]'))
            for file in ${to_load[@]}; do
                to_source=$(echo $file | sed -e 's/^"//' -e 's/"$//')
                source "$to_source"
            done
        else
            files=()
            # The config file does not exist so we will create it
            to_load=($(find "$expanded_path" -name "*.sh" | sed -e 's/\/\//\//g'))
            for script in "${to_load[@]}"; do
                if [[ "$script" != *"load"* ]]; then
                    files+=("$script")
                fi
            done

            let end=${#files[@]}
            echo "Loading ${#files[@]} scripts"
            echo '{"files":[' >config.json
            for index in $(seq 1 $end); do
                if [[ "$index" -eq "${#files[@]}" ]]; then
                    echo "\"${files[$index]}\"" >>config.json
                else
                    echo "\"${files[$index]}\"," >>config.json
                fi
            done
            echo ']}' >>config.json
        fi
    )
fi
