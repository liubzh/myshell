#!/bin/bash

######## Script Information. BGN ########
# Author: liubingzhao.
# Date: 2016-11-16
######## Script Information. END ########

# All the global variables in this script.
function init_global_variables() {
    TARGET_SYSTEM=ubuntu
}

function print_help() {
cat << Help
Binzo's sh file, it can help us to enable myshell.
Help
}

# Parse and validate the arguments.
# return 0: ok
# return 1: invalid or print help.
function parse_and_check_args ()
{
    while [ $# -gt 0 ];do
        case "$1" in
        -h|--help|\?)
            print_help
            return 1    # exit.
            ;;
        -u|--ubuntu)
            TARGET_SYSTEM=ubuntu
            shift
            ;;
        -w|--windows)
            TARGET_SYSTEM=windows
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            return 1
            shift
            ;;
        esac
    done
}

function main() {
    parse_and_check_args "$@"
    case "$?" in
    1)
        return 0
        ;;
    *)
        ;;
    esac

    local target_file="${HOME}/.bashrc"
    if [[ $TARGET_SYSTEM == windows ]]; then
        target_file="${HOME}/.bash_profile"
    fi
    if [[ $(uname) == Darwin ]]; then
        target_file="${HOME}/.bash_profile"
    fi
    local content="source ${HOME}/myshell/source"

    if [ ! -f ${target_file} ]; then
        echo "${target_file} does not exist."
        return 0
    fi
    local search_result=`grep "${content}" ${target_file}`
    if [ -n "${search_result}" ]; then
        if [[ ${search_result} == ${content} ]]; then
            echo "You don't need to write again."
        else
            # eg. if the line starts with #, replace it
            sed -i "s?${search_result}?${content}?" ${target_file}
            echo "Success."
        fi
    else
        # Append content to target file.
        echo "${content}" >> ${target_file}
        echo "Success."
        # Source it to enable myshell immediately.
        ${content}
    fi

    # 如果是64位操作系统，在安装新程序的时候会用到32位库依赖
    # Android Studio的安装，有如下库依赖。
    # sudo apt install lib32z1 lib32ncurses5  lib32stdc++6
    # sudo apt -f install
}

main "$@"
