#!/bin/bash

######## Script Information. BGN ########
# Author: liubingzhao.
#   Date: 2017-10-15
######## Script Information. END ########

function global_variables() {
    FILE_IN=
    DIR_IN=.
    COUNT=
    BUG_TIME=
    OFFSET=2  # 默认偏移量为2分钟以内
    VERBOSE=no
}

function print_help() {
    cat << Help
用法: JE_NE_SWT.sh [选项]
选项:
  [-d|--dir]    : 指定目录，一般为下载好并解压后的目录，默认为当前目录
  [-h|--help|?] : 打印帮助信息
  [-i|--filein] : 一般为 download_log.sh 输出的 bug 列表
  [-o|--offset] : 指定日志时间偏移量，默认为2分钟，超过时间偏移量的日志将被忽略
  [-t|--time]   : 指定问题时间点
  [-v|--verbose]: 输出 TRACE 等信息

示例:
  $ JE_NE_SWT.sh   --offset 3   --dir ~/Log   --filein /tmp/log_url.tmp
  分析下载列表中所有的log
  $ JE_NE_SWT.sh   --dir .   --time 10:30  --verbose
  分析当前目录下时间点为 10:30 左右的 db，--verbose 输出 trace
Help
}

function parse_and_check_args () {
    while [ $# -gt 0 ];do
        case "$1" in
            -h|--help|\?)
                print_help
                exit 0
                ;;
            -i|--filein)
                shift
                FILE_IN="$1"
                shift
                ;;
            -d|--dir)
                shift
                DIR_IN="$1"
                shift
                ;;
            -t|--time)
                shift
                BUG_TIME="$1"
                shift
                ;;
            -o|--offset)
                shift
                OFFSET="$1"
                shift
                ;;
            -v|--verbose)
                VERBOSE=yes
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    # 判断输入目录和输入文件
    if [ -n "${FILE_IN}" -a ! -f "${FILE_IN}" ]; then
        echo "-i 指定的文件不存在"
        exit 1
    fi
    if [ -n "${DIR_IN}" -a ! -d "${DIR_IN}" ]; then
        echo "-d 指定的目录不存在"
        exit 1
    fi

    if [ -n "${FILE_IN}" ];  then echo "FILE_IN='${FILE_IN}'"; fi
    if [ -n "${DIR_IN}" ];   then echo "DIR_IN='${DIR_IN}'";   fi
    if [ -n "${BUG_TIME}" ]; then echo "BUG_TIME='${BUG_TIME}'"; fi
    echo
}

# $1: time in [xx:xx]
# $2: time in [xx:xx]
# echo: time offset
function timeOffset() {
    local h m t1 t2
    h=${1%:*}; h=${h#*0}; m=${1#*:}; m=${m#*0}; t1=$((h*60+m))
    h=${2%:*}; h=${h#*0}; m=${2#*:}; m=${m#*0}; t2=$((h*60+m))
    local offset=$((${t1}-${t2}))
    if ((${offset} < 0)); then
        offset=$((-${offset}))
    fi
    echo $offset
}

# $1: bug_time
# $2: bug_id
function confirm_dbg() {
    local exception_file="__exp_main.txt"
    local bug_time="$1"
    local bug_id="$2"
    local target_log_dir="${DIR_IN}"
    if [ -n "${bug_id}" ]; then
        target_log_dir="${DIR_IN}/${bug_id}"
    fi
    if [ ! -d "${target_log_dir}" ]; then
        echo "${bug_id} 目录不存在"
        return 1
    fi
    local offset=
    local theTime=
    local theLine=
    local expClass=

    local switch_time_kernel_log    #转换时间之后的 kernel_log 路径
    while read line; do
        switch_time_kernel_log="${line}.time"
        if [ ! -f "${switch_time_kernel_log}" ]; then
            kernel_log_time -i "${line}" -o "${switch_time_kernel_log}"
        fi
    done < <(find "${target_log_dir}" -name kernel_log)

    grep -r "FDLEAK" --include=kernel_log.time "${target_log_dir}"
    #local fdleak=$(grep -r "FDLEAK" --include=kernel_log.time "${target_log_dir}")
    #if [ -n "${fdleak}" ]; then
    #    echo "kernel_log 中发现 ‘FDLEAK’"
    #fi

    local appError=$(grep -r "Application Error:" --include=events_log "${target_log_dir}" | wc -l)
    if [ ${appError} -gt 0 ]; then
        echo "events_log 中发现 ‘Application Error:’ 总数：${appError}"
    fi

    while read line; do
        #echo "${line}"
        exp_time=$(grep "Exception Log Time:" "${line}")
        exp_time=${exp_time#*Exception Log Time:[}
        exp_time=${exp_time% CST*}
        exp_time=${exp_time##* }
        exp_time=${exp_time%:*}
        newOffset=$(timeOffset "${exp_time}" "${bug_time}")
        #echo "newOffset ${newOffset}"
        if [ -z "${offset}" ]; then
            offset="${newOffset}"
            theTime=${exp_time}
            theLine=${line}
        fi
        if (( ${newOffset} < ${offset} )); then
            offset="${newOffset}"
            theTime=${exp_time}
            theLine=${line}
        fi
        #echo "LOG时间: ${exp_time}"
        #echo "offset: ${offset}"
        #break
    done < <(find "${target_log_dir}" -name "${exception_file}")
    if [ -n "${offset}" ]; then
        #echo "LOG 时间: ${theTime}"
        if ((${offset} > ${OFFSET})); then
            echo "时间偏移量过大: ${offset} 分钟"
            echo "文件路径: ${theLine}"
            return 1
        fi
        echo "时间偏移: ${offset} 分钟"
        echo "文件路径: ${theLine}"
        expClass=$(grep "Exception Class:" "${theLine}")
        echo "${expClass}"
        if [[ ${VERBOSE} == yes ]]; then 
            #详情模式输出
            if [[ ${expClass} == *\(JE\)* ]]; then
                cat "${theLine}"
                return 0
                echo "${expClass}"
                local isTraceStart="false"
                while read textLine; do
                    if [[ ${textLine} == Exception\ Log\ Time:* ]]; then
                        echo "${textLine}";
                    elif [[ ${textLine} == *Exception:\ * ]]; then
                        isTraceStart="true"
                        echo "${textLine}"
                        continue
                    elif [ -z "${textLine}" ]; then
                        isTraceStart="false"   # 不输出分割线
                    fi
                    if [[ ${isTraceStart} == true ]]; then
                        echo "    ${textLine}"
                    fi
                done < "${theLine}"
            elif [[ ${expClass} == *\(NE\)* ]]; then
                cat "${theLine}"
            elif [[ ${expClass} == *SWT* ]]; then
                cat "${theLine}"
            else
                echo "未知类型"
            fi
        fi
    else
        echo "未过滤到.dbg"
    fi
}

function main() {
    global_variables
    parse_and_check_args "$@"
    local bug_id bug_time
    if [ -n "${FILE_IN}" -a -f "${FILE_IN}" ]; then
        while read line; do
            echo; echo "${line}"
            bug_id=${line#*ID:}; bug_id=${bug_id%,*}
            bug_time=${line#*TIME:}
            confirm_dbg "${bug_time}" "${bug_id}" 
        done < <(grep "^ID:" "${FILE_IN}" | uniq)
    elif [ -n "${BUG_TIME}" ]; then
        confirm_dbg "${BUG_TIME}"
    fi
}

main "$@"
