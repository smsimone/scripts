#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color

function _print_error() {
    echo -e "${RED}$1${NC}"
}

# Clear all svg assets in a given folder with `svgcleaner` utility
function clean_assets() {
    if [[ ! -f "pubspec.yaml" ]]; then
        _print_error "ERROR: This command has to be used inside a flutter project"
        return -1
    fi

    asset_folder=""
    if [[ -n "$1" ]]; then
        asset_folder="$1"
    else
        _print_error "ERROR: Missing assets folder parameter. Usage: 'clean_assets <folder>'"
        return -1
    fi

    if [[ ! "$(command_exists svgcleaner)" ]]; then
        _print_error "ERROR: Missing 'svgcleaner' utility. Install it first"
        return -1
    fi

    files=($(find "$asset_folder" -name "*.svg"))

    for file in $files; do
        echo -n "Cleaning $file: "
        svgcleaner $file $file
    done
}

# Generates all the paths to put in `pubspec.yaml` to import all the assets of the projects
function generate_asset_paths() {
    if [[ ! -f "pubspec.yaml" ]]; then
        _print_error "ERROR: This command has to be used inside a flutter project"
        return -1
    fi

    asset_folder=""
    if [[ -n "$1" ]]; then
        asset_folder="$1"
    else
        _print_error "ERROR: Missing assets folder parameter. Usage: 'generate_asset_paths <folder>'"
        return -1
    fi

    folders=($(find "$asset_folder" -type d))

    for folder in $folders; do
        (
            cd $folder
            numOfDirs=$(find . -type d -d 1 | wc -l)
            numOfFiles=$(find . -type f -d 1 | wc -l)
            if [[ "$numOfDirs" -lt 1 || "$numOfFiles" -ge 2 ]]; then
                echo "- $folder/"
            fi
        )
    done
}

# Updates the project and the sub-projects all together
function update_project() {
    if [[ ! -f "pubspec.yaml" ]]; then
        _print_error "ERROR: This command has to be used inside a flutter project"
        return -1
    fi

    packages_folder=""
    if [[ -n "$1" ]]; then
        packages_folder="$1"
    else
        _print_error "ERROR: Missing subpackages folder parameter. 'update_project <folder>'"
        return -1
    fi

    fvm flutter pub upgrade --major-versions
    for package in $(ls $packages_folder); do
        (cd "$packages_folder/$package" && echo "Updating package $package" && fvm flutter pub upgrade --major-versions)
    done
}
