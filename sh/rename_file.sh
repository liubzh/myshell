#!/bin/bash

######## Script Information. BGN ########
# Author: liubingzhao.
# Date: 2017-01-23
######## Script Information. END ########

# All the global variables in this script.
function init_global_variables() {
    :
}

function print_help() {
    cat << Help
rename_file | Binzo's command.
用法: rename_file [目录|文件]
说明: 重命名一个目录或文件(过滤非法字符，包括空格)，
      如果是目录，会重命名目录中所有目录和文件
Help
}

function parse_and_check_args () {
    :
}

# $1: 需要重命名的字符串
function rename_file() {
    local string="$1"
    string=${string// /_} # replace space to _
    string=${string//[!0-9A-Za-z-,._]/-} # replace unknown characters.
    if [[ ${1} != ${string} ]]; then
        mv "$1" ${string}
        #echo ${string}
    fi
}

# $1: 需要遍历的目录
function iterate_files() {
    local target_out=/tmp/tmpfilelist
    find . -name "*[!0-9A-Za-z-,._]*" > ${target_out}
    local line
    while read line; do
        line=${line#*/}
        rename_file "${line}"
        echo $line
    done < ${target_out}
}

function main() {
    init_global_variables

    # Check arguments.
    parse_and_check_args "$@"
    if (( 0 != $? )); then return 1; fi

    iterate_files "$@"
}

main "$@"
