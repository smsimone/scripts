#!/bin/sh

function extract_apk(){
    if [[ -z "$1" ]]; then
        echo "Missing bundle parameter"
        echo "extract-apks <appbundle.aab>"
    else
        bundletool build-apks --bundle "$1" --output extracted.apks
        jar xf extracted.apks
    fi
}

