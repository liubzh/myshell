#!/bin/bash

# 此脚本是用于写周报的
# 1. 在redmine上进入个人页面，点击‘活动’
# 2. 复制所有要过滤内容到文件
# 3. 运行此脚本

# $1: fileIn
# $2: fileOut
function main() {
    local fileIn="$1"
    local fileOut="$2"
    local verbose=false
    local exists=

    if [ -z "${fileOut}" ]; then
        echo "用法：filter fileIn fileOut [--verbose|-v]"
        exit 1
    elif [ ! -f "${fileIn}" ]; then
        echo "文件不存在：${fileIn}"
        exit 1
    fi
    if [ -f "${fileOut}" ]; then
        rm "${fileOut}"
        touch "${fileOut}"
    fi
    if [[ ${3} == --verbose || ${3} == -v ]]; then
        verbose=true
    fi
    ifs=$IFS; IFS="\n"; # 保留行首制表符和空格
    while read line; do
        exists=
        if [[ ${line} == 201* ]]; then
            if [ -s ${fileOut} ]; then
                printf "\n" >> ${fileOut}
            fi
            printf "${line}:" >> ${fileOut}
            continue
        elif [[ ${line} == *\ GNSPR\ * ]]; then
            line=${line##* GNSPR }
        elif [[ ${line} == *\ GNDCR\ * ]]; then
            line=${line##* GNDCR }
        else
            continue
        fi

        if ${verbose}; then
            # ---详细输出---
            echo "${line}" >> "${fileOut}"
        else
            # ---截取BugId---
            line=${line%%: *}
            line=${line%% (*}
            # ---去重---
            exists=$(tail -n1 ${fileOut} | grep "${line}")
            if [ -z "${exists}" ]; then
                printf "  ${line}" >> "${fileOut}"
            fi
        fi
    done < "${fileIn}"
    
    if [ ! -s ${fileOut} ]; then return; fi

    local the_date week bugs
    printf "\n\n" >> ${fileOut}
    # 按照日期重新排列所有行，并格式化
    while read line; do
        if [[ ${line} == 201* ]]; then
            the_date=${line%%:*}
            week=${the_date//-/}; week=$(date '+%a' --date="${week}")
            printf "周${week}（${the_date}）\n" >> ${fileOut}
        fi
        if [ -z "${line}" ]; then
            continue
        fi
        bugs=${line#*:}
            printf "1、${bugs}\n2、\n3、\n" >> "${fileOut}"
    done < <(sort ${fileOut})
}

main "$@"
