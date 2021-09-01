#!/bin/bash

# Dequarantine a script to make it run
function dequarantine(){
    if [[ -z "$1" ]]; then
        _print_error "ERROR: Missing the script to de-quarantine. Usage: 'dequarantine <script>'"
        return -1
    fi

    scriptdir=$(greadlink -f "$1")
    xattr -d com.apple.quarantine "$scriptdir"
}
