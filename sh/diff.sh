#!/bin/bash

######## Script Information. BGN ########
# Author: liubingzhao.
# Date: 2017-01-23
######## Script Information. END ########

# All the global variables in this script.
function init_global_variables() {
    DIR_OLD=
    DIR_NEW=
    DIR_OUT=.
    PATCH_ZIP_NAME="patch.zip"
    DIR_OUT_TMP="/tmp/tmp_diff"
    if [ -d "${DIR_OUT_TMP}" ]; then rm -r "${DIR_OUT_TMP}"; fi
    mkdir -p "${DIR_OUT_TMP}"
    PATCH_FILE="${DIR_OUT_TMP}/patch.diff"
    BINARY_MAP_FILE="${DIR_OUT_TMP}/binary.map"; if [ -d "${BINARY_MAP_FILE}" ]; then rm "${BINARY_MAP_FILE}"; touch "${BINARY_MAP_FILE}"; fi
    EMPTY_DIR_FILE="${DIR_OUT_TMP}/empty_dirs"
    COMMIT_ID=
    IS_FOR_GIT=no
    CONTAINS_BINARY_FILE=no
}

function print_help() {
    cat << Help
diff.sh | Binzo's customized command 'diff'.
Usage: diff <DIR_OLD> <DIR_NEW> <DIR_OUT>
It generates patch.zip in folder DIR_OUT
Help
}

function parse_and_check_args () {
    while [ $# -gt 0 ]; do
        case "$1" in
        -h|--help|\?)
            print_help
            exit 0
            ;;
        *)
            if [ -e "$1" ]; then
                if [ -z "${DIR_OLD}" ]; then
                    DIR_OLD="$1"
                elif [ -z "${DIR_NEW}" ]; then
                    DIR_NEW="$1"
                else
                    DIR_OUT="$1"
                fi
            elif [ -d ".git" -a $(echo "$1" | grep -E "[0-9a-f]{6,}") -a $(git show "$1" > /dev/null; echo $?) -eq 0 ]; then
                # 是一个有效的 commit id，16进制字符串，6个以上字符，并且 git show 可以找到这个ID
                COMMIT_ID="$1"
                IS_FOR_GIT=yes
                echo "检索到有效 COMMIT ID: ${COMMIT_ID}"
            else
                echo "Directory \"$1\" does not exist."
                exit 1
            fi
            shift
            ;;
        esac
    done
}

function zip_file() {
    if [[ ${CONTAINS_BINARY_FILE} != yes ]]; then
        echo "> ${DIR_OUT}/$(basename "${PATCH_FILE}")"
        cp "${PATCH_FILE}" "${DIR_OUT}"
        return 1
    fi
    local zipfile="${DIR_OUT}/${PATCH_ZIP_NAME}"
    pushd "${DIR_OUT_TMP}" > /dev/null
    echo "Zipping"
    zip "${PATCH_ZIP_NAME}" ./*
    popd > /dev/null
    cp "${DIR_OUT_TMP}/${PATCH_ZIP_NAME}" "${zipfile}"
    if [ -f "${zipfile}" ]; then
        echo "> ${zipfile}"
        #echo "Generated ${PATCH_ZIP_NAME}."
    fi
}

function copy_binary_files() {
    local line old new old_dir new_dir count content
    local filter_banary_tmp="/tmp/binary.info"
    let count=1
    grep "^Binary files" ${PATCH_FILE} > ${filter_banary_tmp}
    if [ -s "${filter_banary_tmp}" ]; then
        CONTAINS_BINARY_FILE=yes
    else
        return 1
    fi
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
        # 如果是 Git 库生成 diff，会有 a/xxx b/xxx 标识，所以忽略第一层目录
        if [[ ${old} != /dev/null ]]; then old=${old#*/}; fi
        if [[ ${new} != /dev/null ]]; then new=${new#*/}; fi
        #echo a old=${old} new=${new}
        #if [ -d $old_dir -a ! -d $new_dir ]; then
        #    old_dir=${old_dir#*/}
        #    content="rmdir : ${old_dir}"
        #elif [ ! -d $old_dir -a -d $new_dir ]; then
        if [[ ${new} == /dev/null ]]; then
            content="rm : ${old}"
        else
            content="cp : ${count} : ${new}"
            cp ${new} ${DIR_OUT_TMP}/${count}
            ((count++))
            echo -e "${content}" >> ${BINARY_MAP_FILE}
        fi
    done < ${filter_banary_tmp}
    rm ${filter_banary_tmp}
    #find ${DIR_NEW} -empty -type d -fprint ${EMPTY_DIR_FILE}
}

function generate_patch() {
    # for git. begin
    if [ -n "${COMMIT_ID}" ]; then
        echo "根据 COMMIT_ID 生成 diff"
        git show "${COMMIT_ID}" > "${PATCH_FILE}"
        return $?
    elif [ -z "${DIR_NEW}" -a -z "${DIR_OLD}" -a -d .git ]; then
        if [ $(git diff --cached --name-only | wc -l) -gt 0 ]; then
            read -p "检索到 cached diff，要生成暂存的差异吗？(Y/y)" ANSWER
            if [[ ${ANSWER} == y || ${ANSWER} == Y ]]; then
                IS_FOR_GIT=yes
                echo "生成 diff --cached"
                git diff --cached > "${PATCH_FILE}"
                return $?
            fi
        fi
        if [ $(git diff --name-only | wc -l) -gt 0 ]; then
            read -p "检索到 diff，要生成差异吗？(Y/y)" ANSWER
            if [[ ${ANSWER} == y || ${ANSWER} == Y ]]; then
                IS_FOR_GIT=yes
                echo "生成 diff"
                git diff > "${PATCH_FILE}"
                return $?
            else
                exit 0
            fi
        else
            echo "没有检测到 diff"
            if [ -n "$(git status -s | grep "^\?\?")" ]; then
                echo "但是发现了新增文件，可以尝试将文件 add 到暂存区再进行尝试"
            fi
        fi
        exit 1
    fi
    # for git. end
    if [ -n "${DIR_NEW}" -a -n "${DIR_OLD}" ]; then
        # Core command of this script below.
        diff -Nur --exclude=.svn --exclude=.git ${DIR_OLD} ${DIR_NEW} > ${PATCH_FILE}
        local result_diff="$?"
        echo "diff command result: ${result_diff}"
        if [ ! -s "${PATCH_FILE}" ]; then
            echo There is no difference between \"${DIR_OLD}\" and \"${DIR_NEW}\"
            return 1
        fi
    else
        echo "没有什么可做的"
        exit 1
    fi
}

function main() {
    init_global_variables

    # Check arguments.
    parse_and_check_args "$@"

    generate_patch
    if (( 0 != $? )); then return 1; fi

    copy_binary_files

    zip_file
}

main "$@"
