#!/bin/bash

######## Script Information. BGN ########
# Author: liubingzhao.
# Date: 2017-01-23
######## Script Information. END ########

# All the global variables in this script.
function init_global_variables() {
    DIR_OLD=
    DIR_NEW=
    DIR_OUT=
    PATCH_ZIP_NAME="patch.zip"
    DIR_OUT_TMP="/tmp/tmp_diff"
    PATCH_FILE="${DIR_OUT_TMP}/patch"
    BINARY_MAP_FILE="${DIR_OUT_TMP}/binary.map"
    EMPTY_DIR_FILE="${DIR_OUT_TMP}/empty_dirs"
}

function print_help() {
    cat << Help
diff.sh | Binzo's customized command 'diff'.
Usage: diff <DIR_OLD> <DIR_NEW> <DIR_OUT>
It generates patch.zip in folder DIR_OUT
Help
}

function parse_and_check_args () {
    if [ $# -gt 3 ]; then
        echo "Too many arguments."
        print_help
        return 1
    fi
    while [ $# -gt 0 ]; do
        case "$1" in
        -h|--help|\?)
            print_help
            return 1    # exit.
            ;;
        *)
            if [ -d "$1" ]; then
                if [ -z "${DIR_OLD}" ]; then
                    DIR_OLD="$1"
                elif [ -z "${DIR_NEW}" ]; then
                    DIR_NEW="$1"
                else
                    DIR_OUT="$1"
                fi
            else
                echo "Directory \"$1\" does not exist."
                return 1
            fi
            shift
            ;;
        esac
    done
    if [ -z "${DIR_OLD}" -o -z "${DIR_NEW}" -o -z "${DIR_OUT}" ]; then
        print_help
        return 1
    fi
}

function zip_file() {
    local zipfile="${DIR_OUT}/${PATCH_ZIP_NAME}"
    local mpwd="`pwd`"
    cd "${DIR_OUT_TMP}"
    zip "${PATCH_ZIP_NAME}" ./*
    cd ${mpwd}
    cp "${DIR_OUT_TMP}/${PATCH_ZIP_NAME}" "${zipfile}"
    if [ -f "${zipfile}" ]; then
        echo "Generated ${PATCH_ZIP_NAME}."
    fi
}

function copy_binary_files() {
    local line old new old_dir new_dir count content
    local filter_banary_tmp="/tmp/binary.info"
    let count=1
    grep "^Binary files" ${PATCH_FILE} > ${filter_banary_tmp}
    while read line; do
        content=
        #echo ${line}
        #echo ${count}
        line=${line#Binary files }
        line=${line% differ}
        old=${line% and *}
        new=${line#* and }
        old_dir=$(dirname $old)
        new_dir=$(dirname $new)
        #echo old=${old} new=${new}
        if [ -d $old_dir -a ! -d $new_dir ]; then
            old_dir=${old_dir#*/}
            content="rmdir : ${old_dir}"
        elif [ ! -d $old_dir -a -d $new_dir ]; then
            new_dir=${new_dir#*/}
            content="mkdir : ${new_dir}"
        elif [ -f $old -a ! -f $new ]; then
            old=${old#*/}
            content="rm : ${old}"
        else
            cp ${new} ${DIR_OUT_TMP}/${count}
            new=${new#*/}
            content="${count} : ${new}"
            ((count++))
        fi
        touch ${BINARY_MAP_FILE}
        if [ -z "`grep "${content}" ${BINARY_MAP_FILE}`" ]; then
            echo "${content}" >> ${BINARY_MAP_FILE}
        fi
    done < ${filter_banary_tmp}
    rm ${filter_banary_tmp}
    #find ${DIR_NEW} -empty -type d -fprint ${EMPTY_DIR_FILE}
}

function generate_patch() {
    if [ -d "${DIR_OUT_TMP}" ]; then
        rm -r ${DIR_OUT_TMP}
    fi
    if [ ! -d "${DIR_OUT_TMP}" ]; then
        mkdir "${DIR_OUT_TMP}"
    fi
    # Core command of this script below.
    diff -Nur --exclude=.svn --exclude=.git ${DIR_OLD} ${DIR_NEW} > ${PATCH_FILE}
    local result_diff="$?"
    echo "diff command result: ${result_diff}"
    if [ ! -s "${PATCH_FILE}" ]; then
        echo There is no difference between \"${DIR_OLD}\" and \"${DIR_NEW}\"
        return 1
    fi
}

function main() {
    init_global_variables

    # Check arguments.
    parse_and_check_args "$@"
    if (( 0 != $? )); then return 1; fi

    generate_patch
    if (( 0 != $? )); then return 1; fi

    copy_binary_files
    
    zip_file
}

main "$@"
