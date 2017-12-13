#!/bin/bash
# Author: Binzo.
# Date: 20171212.

TAR_DIR=~/Develop/android/decompile
if [ ! -d "${TAR_DIR}" ]; then
    mkdir -p "${TAR_DIR}"
fi
cd "${TAR_DIR}"

function download() {
    # 找到最新版本下载地址：https://github.com/pxb1988/dex2jar/releases
    local url="https://github.com/pxb1988/dex2jar/releases/download/2.0/dex-tools-2.0.zip"
    wget "${url}" -P "${TAR_DIR}"
    if [ $? -ne 0 ]; then
       echo "wget error."
       exit 1
    fi
    echo "解压缩 zip"
    unzip dex-tools*.zip
    if [ $? -ne 0 ]; then
        echo "unzip error."
        exit 2
    fi
    local dir=$(find dex2jar* -name *dex2jar.sh)
    dir=$(dirname ${dir})
    # 重命名 dex2jar-2.0 为 dex2jar
    mv "${dir}" dex2jar
    if [ $? -ne 0 ]; then
        echo "rename error."
        exit 2
    fi
    cd dex2jar
    chmod +x *.sh
}

download
# PATH variable has been added in ~/myshell/source
# PATH 环境变量已经在 ~/myshell/source 中指定了
