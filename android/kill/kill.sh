#!/bin/bash

KILL_DIR=/data/local/tmp/kill
PACKAGE_LIST_FILE="${KILL_DIR}/packages.list"
PS_LIST_FILE="${KILL_DIR}/ps.txt"

function main() {
    ps -A | grep "^u0_" > ${PS_LIST_FILE}
    local pkg
    while read line; do
        if [[ ${line} == @* || ${line} == \#* ]]; then
            continue   # 略过 # 注释掉的应用，以及 @ 标明的白名单
        fi
        pkg=${line#*: }
        if [ -n "$(grep ${pkg} ${PS_LIST_FILE})" ]; then
            echo "${line}"
            am force-stop ${pkg}
        fi
    done < ${PACKAGE_LIST_FILE}
}

main "$@"
