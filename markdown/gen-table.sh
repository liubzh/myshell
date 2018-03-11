#!/bin/bash

while read line; do
    line=${line//\&/&amp;}  # 所有 & 符号替换为转义字符
    line=${line//\ /&nbsp;} # 所有空格替换为转义字符
    line=${line//\*/&\#42;}  # 所有 * 号替换为转义字符
    line=${line//\|/&\#124;}  # 所有 * 号替换为转义字符
    line=${line//\\/&\#92;}  # 所有 * 号替换为转义字符
    string="|"
    for item in $line; do
        string="${string} ${item} |"
    done
    echo ${string}
    #break
done < "$@"
