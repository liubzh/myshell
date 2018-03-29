#!/bin/bash

function main() {
    DATA_FILE=$(dirname "$0")/packages.list
    local pkg
    while read line; do
        pkg=${line#*: }
        echo "adb uninstall ${pkg}"
        adb uninstall ${pkg}
    done < ${DATA_FILE}
}

main "$@"
