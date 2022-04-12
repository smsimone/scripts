#!/bin/bash

# Dequarantine a script to make it run
function dequarantine() {
    if [[ -z "$1" ]]; then
        _print_error "ERROR: Missing the script to de-quarantine. Usage: 'dequarantine <script>'"
        return -1
    fi

    scriptdir=$(greadlink -f "$1")
    xattr -d com.apple.quarantine "$scriptdir"
}

# Deletes all the local branches of a git repository that does not exist anymore
# on the remote
function remove_old_branches() {
    git fetch -p && for branch in $(git branch -vv | grep ': gone]' | awk '{print $1}'); do git branch -D $branch; done
}

clear_history() {
    echo "" >~/.zsh_history &
    exec "$SHELL" -l
}
