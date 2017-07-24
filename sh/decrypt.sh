#!/bin/bash

######## Script Information. BGN ########
# Author: liubingzhao.
# Date: 2017-07-24
# Introduction: Customized script to decrypt files.
######## Script Information. END ########

# All the global variables in this script.
function init_global_variables() {
    THE_KEY=
}

function print_help() {
    cat << Help
decrypt.sh | 解密文件或文件夹。
用法： decrypt.sh [文件|目录]...
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
            shift
            ;;
        esac
    done
}

# $1: 文件输入
function decrypt() {
    openssl enc -des-ede3-cfb -in "${1}" -out "${1%.enc*}.dec" -d -k "${THE_KEY}"
    if [ $? -eq 0 ]; then
        echo "解密文件：${1} --> ${1%.enc*}.dec"
    else
        echo "解密文件失败：${1}"
    fi
}

# 遍历目录
function iterate_dir() {
    if [ -d "${1}" ]; then
        local items=*
        if [ -z "${items}" ]; then
            # 目录为空
            return 0
        fi
        local item
        while read item; do
            item="${1}/${item}"
            if [ -d "${item}" ]; then
                iterate_dir "${item}"
            else
                if [[ ${item} == *.enc ]]; then
                    decrypt "${item}"
                fi
            fi
        done < <(ls "${1}")
    fi
}

function main() {
    init_global_variables
    parse_and_check_args "$@"
    if [ -z "${THE_KEY}" ]; then
        read -s -p "输入密钥：" THE_KEY
        echo
    fi
    local item
    for item in "$@"; do
        if [ -d "${item}" ]; then
            if [[ ${item} == */ ]]; then
                item=${item%/*} # 如果路径以 / 结尾,则删掉末尾 /
            fi
            iterate_dir "${item}"
        elif [ -f "${item}" ]; then
            decrypt "${item}"
        else
            echo "未找到文件或目录:${item}"
        fi
    done
}

main "$@"
