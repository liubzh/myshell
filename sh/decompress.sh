#!/bin/bash

######## Script Information. BGN ########
# Author: liubingzhao.
# Date: 2017-01-19
######## Script Information. END ########

#if mount error below:
#  "mount: wrong fs type, bad option, bad superblock on smb://10.8.0.10/sw-deliveryed/..."
#do this :
#  sudo apt-get install smbfs
#  sudo apt-get install nfs-common

# All the global variables in this script.
function init_global_variables() {
    :
}

function print_help() {
    cat << Help
decompress.sh | Binzo's own decompression tool.
Usage: decompress.sh <PATH>...
Help
}

# Parse and validate the arguments.
# return 0: ok
# return 1: invalid or print help.
function parse_and_check_args () {
    local illegal_arg=false
    while [ $# -gt 0 ];do
        case "${1}" in
        -h|--help|\?)
            print_help
            exit 0
            ;;
        *)
            if [ ! -f "${1}" ]; then
                echo "没有这个文件： \"${1}\""
                illegal_arg=true
            fi
            shift
            ;;
        esac
    done
    if ${illegal_arg}; then
        exit 1  # 参数非法，退出
    fi
}

function main() {
    init_global_variables

    # Check arguments.
    parse_and_check_args "$@"

    local ret=
    local target_dir=
    for item in "$@"; do
        echo "${item}"
        target_dir="${item}.DEC"
        if [ ! -d "${target_dir}" ]; then
            mkdir "${target_dir}"
        fi
        if [[ ${item} == *.zip ]]; then
            unzip "${item}" -d "${target_dir}"
            ret=$?
        elif [[ ${item} == *.rar ]]; then
            if [ ! -d "${target_dir}" ]; then
                mkdir -p "${target_dir}"
            fi
            echo "rar"
            unrar x "${item}" "${target_dir}"
            ret=$?
        elif [[ ${item} == *.7z ]]; then
            7z x "${item}" -r -o"${target_dir}"
            ret=$?
        elif [[ ${item} == *.tar.gz ]]; then
            tar -xzvf "${item}" -C "${target_dir}"
            ret=$?
        else
            echo "不支持的压缩类型或者不需要解压"
            exit 1
        fi
        if [ ${ret} -ne 0 ]; then
            echo "可能解压失败，请确认: \"${target_dir}\""
            exit ${ret}
        fi
        if [[ ${target_dir} == */roShare/* ]]; then
            ls -al "${target_dir}"
            echo "chmod 755"
            chmod 755 "${target_dir}"
        fi
    done
}

main "$@"
