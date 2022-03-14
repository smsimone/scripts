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
        svgcleaner "$file" "$file"
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
        cd "$folder"
        numOfDirs=$(find . -type d -d 1 | wc -l)
        numOfFiles=$(find . -type f -d 1 | wc -l)
        if [[ "$numOfDirs" -lt 1 || "$numOfFiles" -ge 2 ]]; then
            echo "- $folder/"
        fi
    )
done
}

# Launch a `flutter clean` command on the main project and (optionally on the sub projects)
function clean_project() {
    if [[ ! -f "pubspec.yaml" ]]; then
        _print_error "ERROR: This command has to be used inside a flutter project"
        return -1
    fi

    fvm flutter clean

    other_pubspecs=$(find . -name "pubspec.yaml")
    for package in $other_pubspecs; do
        folder=$(echo "$package" | sed -e "s/pubspec.yaml//g")
        echo "Cleaning folder $folder"
        (cd "$folder" && fvm flutter clean)
    done
}

function upload_dsym() {
    if [[ ! -f "pubspec.yaml" ]]; then
        _print_error "ERROR: This command has to be used inside a flutter project"
        return -1
    fi

    find . -name "*.dSYM" | xargs -I \{\} ios/Pods/FirebaseCrashlytics/upload-symbols -gsp ios/Runner/GoogleService-Info.plist -p ios \{\}
}

function clean_ios_folder() {
    if [[ ! -f "pubspec.yaml" ]]; then
        _print_error "ERROR: This command has to be used inside a flutter project"
        return -1
    fi

    (
    cd ios &&
        (rm Podfile.lock||echo "Lock file doesn't exists") &&
        pod deintegrate &&
        pod repo update &&
        pod install
}
