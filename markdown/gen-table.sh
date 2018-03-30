#!/bin/bash

while read line; do
    line=${line//\&/&amp;}  # 转义 &
    #line=${line//\ /&nbsp;} # 转义空格
    line=${line//\*/&\#42;}  # 转义 *
    line=${line//\|/&\#124;}  # 转义 |
    line=${line//\\/&\#92;}  # 转义 \
    line=${line//	/ \| }  # 将 tab 替换为 |
    echo "| ${line} |"
    #string="|"
    #for item in $line; do
    #    string="${string} ${item} |"
    #done
    #echo ${string}
    #break
    last_line="${line}"
done < "$@"
