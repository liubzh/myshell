#!/bin/bash

cd ~
# 创建 HOME 目录下个人常用目录
DIRs="Apks Applications bin Develop JE Log Patches Projects"
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

# 如果 HOME 目录下的目录为中文，重命名为英文
CONFIG_FILE=~/.config/user-dirs.dirs
FROM=(公共的 模板 视频 图片 下载 文档 音乐 桌面)
TO=(Public Templates Videos Pictures Downloads Documents Music Desktop)
let index=0
let count=${#FROM[@]}
while ((index < count - 1)); do
    from=${FROM[index]}
    to=${TO[index]}
    if [ -d "${from}" ]; then
        echo "${FROM[index]} --> ${TO[index]}"
        mv "${FROM[index]}" "${TO[index]}"
        sed -i "s/${from}/${to}/g" "${CONFIG_FILE}"
    fi
    ((index++))
done
echo "配置文件：~/.config/user-dirs.dirs"
