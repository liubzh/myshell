#!/bin/bash

TAR_DIR=~/Applications/rar
if [ ! -d "${TAR_DIR}" ]; then
    mkdir -p "${TAR_DIR}"
fi
cd "${TAR_DIR}"

function download_file() {
    # 找到对应操作系统的最新版本下载地址：https://www.rarlab.com/download.htm
    URL="https://www.rarlab.com/rar/rarosx-5.5.0.tar.gz"
    wget "${URL}" -P "${TAR_DIR}"
    echo "解压缩 tar.gz"
    tar -xzvf *.tar.gz
}

function install_rar() {
    cd rar*
    echo "安装'rar'"
    sudo install -c -o $USER rar /usr/local/bin
    echo "安装'unrar'"
    sudo install -c -o $USER unrar /usr/local/bin
}

download_file
install_rar
