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
    git fetch -p && for branch in $(git branch -vv | grep ': gone]' | awk '{print $1}'); do git branch -D "$branch"; done
}

# Updates all the branches in the current git repository
function update_all_branches() {
    curr_branch=$(git branch | grep '*' | awk -F' ' '{print $2}')

    to_commit=$(git status | grep 'nothing to commit')

    if [ -z "$to_commit" ]; then
        git add . && git stash
    fi

    for branch in $(git branch); do
        if [[ "$branch" != "$curr_branch" ]]; then
            git checkout "$branch"
            git pull
        fi
    done

    git checkout "$curr_branch"

    if [ -z "$to_commit" ]; then
        git stash pop
    fi
}

clear_history() {
    echo "" >~/.zsh_history &
    exec "$SHELL" -l
}
