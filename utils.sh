#!/bin/bash

function command_exists() {
    if [[ -z "$1" ]]; then
        _print_error "ERROR: Missing #1 parameter"
        echo 0
        return 0
    fi

    if [[ ! -x "$(command -v $1)" ]]; then
        echo 0
        return 0
    fi

    echo 1
    return 1
}
