#!/bin/bash
APKS_DIR=$(dirname "$0")/data_apks
function main() {
    local cmd
    for item in $(ls ${APKS_DIR}); do
        cmd="adb install -r ${APKS_DIR}/${item}"
        echo "${cmd}"; ${cmd}
    done
}

main "$@"
