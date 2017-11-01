#!/bin/bash

# TP 点击事件: InputReader:
# 08-24 09:43:44.865  1656  1777 D InputReader: AP_PROF:AppLaunch_dispatchPtr:Down:54898603, ID:0, Index:1860556824
# 08-24 09:43:45.032  1656  1777 D InputReader: AP_PROF:AppLaunch_dispatchPtr:Up:54898771, ID:1, Index:1860560216

# 按键：
# 08-12 15:18:32.209  1777  2743 D WindowManager: interceptKeyTi keyCode=24 down=true repeatCount=0 keyguardOn=false mHomePressed=false canceled=false metaState:0
# 08-12 15:18:32.581  1777  2744 D WindowManager: interceptKeyTq keycode=26 interactive=true keyguardActive=false policyFlags=22000000 down =false canceled = false isWakeKey=false mVolumeDownKeyTriggered =false mVolumeUpKeyTriggered =false result = 1 useHapticFeedback = false isInjected = false

function main() {
    parse_and_check_args "$@" 
    if [ ! -d ${FILTER_DIR} ]; then
        mkdir ${FILTER_DIR}
    else
        if [ -n "`ls ${FILTER_DIR}`" ]; then
            rm ${FILTER_DIR}/*
        fi
    fi
    local FILTER_FILENAME=filter # filter1 filter2 filter3

    local index=0
    local filter_from_file filter_to_file
    echo "停止过滤输入: c"
    while true; do
        if [ -z "${KEYWORD}" ]; then
            read -p "- 请输入过滤关键字: " KEYWORD
            if [ -z "${KEYWORD}" ]; then
                echo "输入为空"
                continue
            elif [[ ${KEYWORD} == c ]]; then
                break
            fi
        fi
        if ((index==0)); then
            filter_to_file=${FILTER_DIR}/${FILTER_FILENAME}${index}
            do_search ${filter_to_file}
            ((index++))
        else
            filter_from_file=${FILTER_DIR}/${FILTER_FILENAME}$((index-1))
            filter_to_file=${FILTER_DIR}/${FILTER_FILENAME}$((index))
            do_search ${filter_to_file}
            ((index++))
        fi
        if [ -n "${filter_to_file}" ]; then
            if [ -f ${filter_to_file} ]; then
                gedit ${filter_to_file} &
            fi
        fi
        KEYWORD=
    done
}

# $1: 将搜索结果保存到文件路径
function do_search() {
    local keyword=
    local CMD=
    if [[ ${KEYWORD} == *\&* ]]; then
        #echo "包含字符 & "
        while [[ ${KEYWORD} == *\&* ]]; do
            keyword=${KEYWORD%%&*}; KEYWORD=${KEYWORD#*&}
            #echo keyword=${keyword} KEYWORD=${KEYWORD}
            if [ -z "${CMD}" ]; then
                CMD="grep -rni \"${keyword}\" ${FILES}"
            else
                CMD="${CMD} | grep -i \"${keyword}\""
            fi
        done
        CMD="${CMD} | grep -i \"${KEYWORD}\""
    elif [[ ${KEYWORD} == *\|* ]]; then
        #echo "包含字符 | "
        CMD="grep -Enri \"${KEYWORD}\" ${FILES}"
    else
        # 单独关键字
        if [[ ${FILES} == ${FILTER_DIR}* ]]; then
            CMD="grep -ri \"${KEYWORD}\" ${FILES}"
        else
            CMD="grep -rni \"${KEYWORD}\" ${FILES}"
        fi
    fi
    echo CMD: ${CMD}
    eval ${CMD} > $1
    FILES=$1
}

FILES=
KEYWORD=
FILTER_DIR=/tmp/filter

function print_help() {
    echo "filter: 过滤log信息的定制化命令"
}

function parse_and_check_args() {
    while [ $# -gt 0 ];do
        case "$1" in
            -h|--help|\?)
                print_help
                exit 0
                ;;
            *)
                if [ -d "$1" -o -f "$1" ]; then
                    FILES="${FILES} $1"
                else
                    KEYWORD="$1"
                fi
                shift
                ;;
        esac
    done
    if [ -z "${FILES}" ]; then
        FILES=.
    fi
    #echo FILES=${FILES}
    #echo KEYWORD=${KEYWORD}
}

main "$@"
