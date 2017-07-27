#!/bin/bash

TAR_DIR=~/Applications/wechat
if [ ! -d "${TAR_DIR}" ]; then
    mkdir -p "${TAR_DIR}"
fi
cd "${TAR_DIR}"

# 通过下载源码安装
function source_install() {
    # Clone this repository
    git clone https://github.com/geeeeeeeeek/electronic-wechat.git

    # Go into the repository
    cd electronic-wechat

    # Switch branch
    git branch mybranch-production remotes/origin/production
    git checkout mybranch-production

    # Install dependencies and run the app
    npm install && npm start
}

# 通过二进制安装包进行安装
function binary_install() {
    # 如果源码安装失败，那就下载安装包进行验证吧
    # 找到最新版本下载地址：https://github.com/geeeeeeeeek/electronic-wechat/releases
    URL="https://github.com/geeeeeeeeek/electronic-wechat/releases/download/V2.0/linux-x64.tar.gz"
    wget "${URL}" -P "${TAR_DIR}"
    echo "解压缩 tar.gz"
    tar -xzvf *.tar.gz
}

#source_install
binary_install
