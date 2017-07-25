#!/bin/bash

# 创建 HOME 目录下我的常用目录

DIRs="apk application bin develop je log patch project"

cd ~
for item in ${DIRs}; do
    if [ ! -d "${item}" ]; then
        mkdir "${item}"
        if [ $? -eq 0 ]; then
            echo "已创建目录：${item}"
        fi
    else
        echo "目录 ${item} 已存在"
    fi
done
