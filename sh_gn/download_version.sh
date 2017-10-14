#!/bin/bash

# Originally created by liubingzhao on 2017-08-21

function pick_file(){
    local path=.
    local selection=
    while true; do
        if [ -d ${path}/*_ANDROID ]; then
            path=$(ls -d ${path}/*ANDROID)
            continue
        elif [ -f ${path}/*.7z ]; then
            path=$(ls ${path}/*.7z)
            break
        fi
        selection=
        while [ -z "${selection}" ]; do
            select selection in $(ls -r ${path}); do
                :
                break
            done
        done
        path="${path}/${selection}"
        if [ -f "${path}" ]; then
            break
        elif [ -d "${path}" ]; then
            continue
        else
            break
        fi
    done
    URL="${URL}/${path#*./}"
}

function download_file() {
    TARGET_DIR=~/roShare/Version
    echo "URL=${URL}"
    wget "$URL" -P "${TARGET_DIR}"
    decompress.sh "${TARGET_DIR}/$(basename ${URL})"
}

function main() {
    DIR=~/Server
    if [ ! -d "${DIR}" ]; then
        mkdir "${DIR}"
    fi
    URL="ftp://gnftp:gionee@10.8.0.22/software_release/git_release"
    sudo curlftpfs -o rw,allow_other "${URL}" "${DIR}"
    pushd "${DIR}" > /dev/null
    pick_file "$@"
    echo "${URL}"
    popd > /dev/null
    sudo umount "${DIR}"
    download_file
}

main "$@"
