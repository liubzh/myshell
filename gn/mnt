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
    PRE_TEXTDOMAINDIR=$TEXTDOMAINDIR
    PRE_TEXTDOMAIN=$TEXTDOMAIN
    my_cmd=
    mnt_target=~/Server/mnt
    DIR_VERSION=~/Version
    DIR_LOG=~/Log
    extract_target=
    server_info=${MYSHELLDATADIR}/mnt/info
    target_dir=
    target_file=
}

function print_help() {
    cat << Help
$(gettxt "mnt | Binzo's own command to mount remote filesystem.")
$(gettxt 'Usage:') mnt [PATH]
Help
}

# Parse and validate the arguments.
# return 0: ok
# return 1: invalid or print help.
function parse_and_check_args () {
    while [ $# -gt 0 ];do
        case "$1" in
        -h|--help|\?)
            print_help
            return 1    # exit.
            ;;
        *)
            shift
            ;;
        esac
    done
}

# Internationalization and localization
# Set local language support. only for zh_CN.
# Reference directory: /usr/local/share/locale
function set_localization() {
    export TEXTDOMAINDIR="${MYSHELLDIR}/lang/locale"
    export TEXTDOMAIN="mnt"
}

function unset_localization() {
    if [ -z "$PRE_TEXTDOMAINDIR" ]; then
        unset TEXTDOMAINDIR
    else
        export TEXTDOMAINDIR="${PRE_TEXTDOMAINDIR}"
    fi
    if [ -z "$PRE_TEXTDOMAIN" ]; then
        unset TEXTDOMAIN
    else
        export TEXTDOMAIN="${PRE_TEXTDOMAIN}"
    fi
}

function rename_file() {
    local string="$1"
    string=${string// /_} # replace space to _
    string=${string//[!0-9A-za-z-,._]/-} # replace unknown characters.
    if [[ ${1} != ${string} ]]; then
        mv "$1" ${string}
    fi
}

function main() {
    init_global_variables

    # Check arguments.
    parse_and_check_args "$@"
    case "$?" in
    1)
        return 1
        ;;
    *)
        ;;
    esac

    if [[ `pwd` == ${mnt_target}* ]]; then
        echo "Escape from ${mnt_target}."
        cd ~
    fi

    if [ ! -d ${mnt_target} ]; then
        # mkdirs if target directory does not exist.
        mkdir -p ${mnt_target}
    elif [ -n "$(ls ${mnt_target})" ]; then
        # unmount directory if it's not empty
        sudo umount ${mnt_target}
        chk_return
    fi

    local url="$1"
    local m_file=
    local server=
    if [[ ${url} == *.0.22/* ]]; then
        server=".0.22"
    elif [[ ${url} == *.0.23/* ]]; then
        server=".0.23"
    elif [[ ${url} == *.0.162/* ]]; then
        server=".0.162"
    elif [[ ${url} == *.10.22/* ]]; then
        server=".10.22"
    fi
    if [ -z "${server}" ]; then
        echo "Unknown server."
        return 1
    fi
    if [[ ${url} == *.zip || ${url} == *.rar || *.7z || *.mp4 ]]; then
        m_file=$(basename "${url}")
        url=${url%*${m_file}}
    fi
    my_cmd="$(grep ${server//./\\.} ${server_info})${url#*${server}} ${mnt_target}"
    echoW ${my_cmd}

    read -p "Continue <Enter>? " ANSWER
    if [ -n "${ANSWER}" ]; then
        return 1
    fi
    # do mount
    ${my_cmd}
    chk_return
    cd ${mnt_target}

    if [ -d ${m_file} ]; then
        cd ${m_file}
    elif [ -n "${m_file}" ]; then
        if [ ! -f ${m_file} ]; then
            echo "No such file or directory: ${m_file}"
            return 1
        fi
        target_dir="${DIR_LOG}/${m_file%.*}"
        du -BM ${m_file}
        read -p "${m_file} is detected, cp it to ${target_dir}(y/n)? " ANSWER
        if [[ ${ANSWER} == y || ${ANSWER} == Y ]]; then
            target_file="${target_dir}/${m_file}"
            if [ ! -d "${target_dir}" ]; then
                mkdir -p ${target_dir}
            else
                echo "Dir ${target_dir} already exists, you have to extract manually."
                return 1
            fi
            if [ ! -f "${target_file}" ]; then
                cp -v "${m_file}" "${target_file}"
                chk_return
                if [[ ${m_file} == *.zip ]]; then
                    unzip "${target_file}" -d "${target_dir}"
                    chk_return
                elif [[ ${m_file} == *.rar ]]; then
                    unrar x ${target_file} ${target_dir}
                    chk_return
                elif [[ ${m_file} == *.7z ]]; then
                    7z e ${target_file} -o${target_dir} 
                fi
            else
                echo "File ${m_file} already exists."
            fi
            cd ${target_dir}
            for item in *; do
                rename_file "${item}"
            done
            nautilus .
        fi
    fi
    if [[ ${server} == .0.22 ]]; then
        # Server to download versions.
        if [ -f *.7z ]; then
            local file_7z="`ls *.7z`"
            extract_target="${DIR_VERSION}/${file_7z%.7z*}"
            read -p "${file_7z} is detected, extract it to ${extract_target}(y/n)? " ANSWER
            if [[ ${ANSWER} == y || ${ANSWER} == Y ]]; then
                if [ ! -d "${extract_target}" ]; then
                    mkdir -p ${extract_target}
                else
                    echo "Dir ${extract_target} already exists, you have to extract manually."
                    return 1
                fi
                du -BM ${file_7z}
                7z e ${file_7z} -o${extract_target}
                cd ${extract_target}
            fi
        fi
    fi
}

set_localization
main "$@"
unset_localization
