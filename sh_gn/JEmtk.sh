#!/bin/bash

######## Script Information. BGN ########
# Author: liubingzhao.
#   Date: 2017-05-19
######## Script Information. END ########

function global_variables() {
    FILE_IN=
    FILE_OUT=
    DIR_IN=
    DIR_OUT=
    COUNT=
    RESULT_FILE=
}

function print_help() {
    cat << Help
用法: JEmtk.sh [选项]
选项:
  [-h|--help|?]    :    打印帮助信息
  [-i|--filein]    :    指定输入文件，比如：JE.csv，一般为下载地址列表
  [-o|--fileout]   :    指定输出文件，一般为异常统计文件
  [-I|--dirin]     :    指定输入目录，一般为下载好并解析后的目录
  [-O|--dirout]    :    指定输出目录，缺省值默认为：~/JE_DIR
示例:
  $ JE.sh -i JE.csv -O JE_DIR  
  下载 JE.csv 文件中列出的所有的 .dbg 文件到目录 ~/JE_DIR 中并解压
  $ JE.sh -I JE_DIR -O JE_OUT
  过滤 JE_DIR 目录下所有异常，输出到目录 ~/JE_OUT 下，分析报告存入 result.txt 中
Help
}

function parse_and_check_args () {
    while [ $# -gt 0 ];do
        case "$1" in
            -h|--help|\?)
                print_help
                return 1    # exit.
                ;;
            -i|--filein)
                shift
                FILE_IN="$1"
                shift
                ;;
            -o|--fileout)
                shift
                FILE_OUT="$1"
                shift
                ;;
            -I|--dirin)
                shift
                DIR_IN="$1"
                shift
                ;;
            -O|--dirout)
                shift
                DIR_OUT="$1"
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
        return 1
    fi
    if [ -n "${DIR_IN}" -a ! -d "${DIR_IN}" ]; then
        echo "-I 指定的目录不存在"
        return 1
    fi
    if [ -z "${DIR_IN}" -a -z "${FILE_IN}" ]; then
        echo "输入文件 或 输入目录 均未指定，无法执行"
        return 1
    fi
    # 输入目录和输出目录不能相同
    if [[ ${DIR_IN} == ${DIR_OUT} ]]; then
        echo "输入目录 与 输出目录 不能为相同路径"
        return 1
    fi
    
    # 设定变量默认值
    if [ -z ${DIR_OUT} ]; then
        DIR_OUT=~/JE/JE_DIR
    fi
    if [ -z ${FILE_OUT} ]; then
        FILE_OUT=/tmp/result
    fi
    # 判断输出目录
    if [ -d ${DIR_OUT} ]; then
        read -p "输出目录 '${DIR_OUT}' 已存在，确定覆盖？(y/n)" ANSWER
        if [[ ${ANSWER} == y || ${ANSWER} == Y ]]; then
            rm -r ${DIR_OUT}
        else
            return 1
        fi
    fi
    # 创建输出目录
    mkdir -p ${DIR_OUT}
    if [ $? -ne 0 ]; then
        return 1
    fi

    echo "FILE_IN=${FILE_IN}"
    echo "FILE_OUT=${FILE_OUT}"
    echo "DIR_IN=${DIR_IN}"
    echo "DIR_OUT=${DIR_OUT}"
}

function parse_url_and_download() {
    if [ -z "${FILE_IN}" -o ! -f "${FILE_IN}" ]; then
        return 1
    fi
    local index=0
    local count=$(grep "http:" -c ${FILE_IN})
    local line
    while read line; do
        if [[ ${line} == *http://* ]]; then
            ((index++))
            line="http://${line#*http://}"
            line="${line%%.dbg*}.dbg"
            echo "开始下载第 ${index}/${count} 个"
            wget "${line}" -P "${DIR_OUT}"
            local ret=$?
            echo "ret=${ret} ${line}" >> "${DIR_OUT}/download.log"
        
        fi
    done < ${FILE_IN}
    echo "解析 .dbg"
    echo "QAAT jar file: $(dirname $0)/QAAT-ProGuard.jar"
    echo "QAAT aee_extract: $(dirname $0)/aee_extract"
    java -jar $(dirname $0)/QAAT-ProGuard.jar -d ${DIR_OUT} -a true -w true -o ${DIR_OUT}/mtk_result.txt
}

function parse_exceptions() {
    local exception_file="__exp_main.txt"
    local exception_path=
    local search exp_msg i count=0
    local include_msg=":[0-9]+\)$"        # 过滤多个关键字: ".java:|xxx"
    local exclude_msg="ArrayList.java:"   # 排除多个关键字: "ArrayList.java:|xxx.java"

    local index=0
    for i in ${DIR_IN}/* ; do
        if [ -d "${i}" ]; then
            exception_path=$(find "${i}" -name "${exception_file}")
            if [ -n "${exception_path}" ]; then
                ((count++))
                exp_msg=$(grep -E "${include_msg}" ${exception_path} | grep -vE "${exclude_msg}" | head -n1)
                echo "${i}"
                echo "${exp_msg}"
                search=$(grep -r "${exp_msg}" ${DIR_OUT})
                search=${search%%:*}
                if [ -z "${search}" ]; then
                    ((index++))
                    local fname=$(printf %03d ${index})
                    echo "新类型：${fname}"
                    echo "${exception_path}" > "${DIR_OUT}/${fname}"
                    cat "${exception_path}" >> "${DIR_OUT}/${fname}"
                else
                    echo "已存在：$(basename ${search})"
                    echo "" >> "${search}"
                    echo "----------" >> "${search}"
                    echo "${exception_path}" >> "${search}"
                    cat "${exception_path}" >> "${search}"
                fi
            fi
        fi
    done
    COUNT=${count}
    echo "总共分析 ${COUNT} 个，有 ${index} 种异常类型。" | tee -a "${FILE_OUT}"

    local parsed_count=0
    for i in ${DIR_OUT}/* ; do
        exp_msg=$(grep -E "${include_msg}" "${i}" | grep -vE "${exclude_msg}" | head -n1)
        count=$(grep -r "${exp_msg}" --include="${exception_file}" "${DIR_IN}" | wc -l)
        ((parsed_count+=count))
        mv "${i}" "${DIR_OUT}/$(printf %03d ${count})$(basename ${i})"
    done

    echo "按概率由高到低排列如下: " | tee -a "${FILE_OUT}"
    while read line ; do
        exp_msg=$(grep -E "${include_msg}" "${DIR_OUT}/${line}" | grep -vE "${exclude_msg}" | head -n1)
        count=$(grep "${exp_msg}" "${DIR_OUT}/${line}" | wc -l)
        echo "概率: ${count}/${COUNT} - 编号: ${line}" | tee -a "${FILE_OUT}"
        grep "Exception: " "${DIR_OUT}/${line}" | head -n1 | tee -a "${FILE_OUT}"
        grep -E "${include_msg}" "${DIR_OUT}/${line}" | grep -vE "${exclude_msg}" | head -n1 | tee -a "${FILE_OUT}"
    done < <(ls -r ${DIR_OUT})

    echo "分析结果累计总数: ${parsed_count}/${COUNT}" | tee -a "${FILE_OUT}"

    RESULT_FILE=${DIR_OUT}/result.txt
    mv ${FILE_OUT} ${RESULT_FILE}

    gedit "${RESULT_FILE}" &
    nautilus "${DIR_OUT}"
}

function main() {
    global_variables
    parse_and_check_args "$@"
    if [ $? -ne 0 ]; then return 1; fi
    if [ -n "${FILE_IN}" ]; then
        parse_url_and_download
    elif [ -n "${DIR_IN}" ]; then
        parse_exceptions
    fi
}

main "$@"
