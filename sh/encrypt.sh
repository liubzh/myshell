#!/bin/bash

######## Script Information. BGN ########
# Author: liubingzhao.
# Date: 2017-07-24
# Introduction: Customized script to encrypt files.
######## Script Information. END ########

# All the global variables in this script.
function init_global_variables() {
    THE_KEY=
}

function print_help() {
    cat << Help
encrypt.sh | 加密一个或多个文件。
用法： encrypt.sh [文件]...
Help
}

# Parse and validate the arguments.
function parse_and_check_args () {
    if [ -z "${1}" ]; then
        print_help
        exit 0
    fi
    while [ $# -gt 0 ];do
        case "${1}" in
        -h|--help|\?)
            print_help
            exit 0 
            ;;
        *)
            if [ -d "${1}" ]; then
                echo "暂不支持加密文件夹"
                exit 1
            fi
            shift
            ;;
        esac
    done
}

# $1: 文件输入
function encrypt() {
    if [ -z "${THE_KEY}" ]; then
        local key
        local key_confirm
        read -s -p "输入密钥：" key
        echo
        read -s -p "确认密钥：" key_confirm
        echo
        if [[ ${key} == ${key_confirm} ]]; then
            THE_KEY="${key}"
        else
            echo "两次输入的密钥不匹配"
            exit 1
        fi
    fi
    openssl enc -des-ede3-cfb -in "${1}" -out "${1}.enc" -k "${THE_KEY}"
    if [ $? -eq 0 ]; then
        echo "加密文件：${1} --> ${1}.enc"
    else
        echo "加密文件失败：${1}"
    fi
}

function main() {
    init_global_variables
    parse_and_check_args "$@"
    local item
    for item in "$@"; do
        if [ -f "${item}" ]; then
            encrypt "${item}"
        else
            echo "未找到文件:${item}"
        fi
    done
}

main "$@"
