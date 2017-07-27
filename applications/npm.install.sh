#!/bin/bash

# apt-get install 一般安装：
function apt_install() {
    sudo apt-get install npm
}

function download_binary_install() {
    # 如果默认 npm 版本不满足需求，需要使用其它版本的时候，可以使用以下方式：
    TAR_DIR=~/Applications/npm
    if [ ! -d "${TAR_DIR}" ]; then
        mkdir -p "${TAR_DIR}"
    fi
    cd "${TAR_DIR}"
    # npm 官网：https://www.npmjs.com/
    # 下载最新版本 npm：https://nodejs.org/en/ 确认最新稳定版之后下载
    echo 下载指定版本:
    VERSION="https://nodejs.org/dist/v6.11.1/node-v6.11.1-linux-x64.tar.xz"
    wget "${VERSION}"
    
    echo 解压缩:
    xz -d node*
    tar -xvf node*
    cd node*
    
    echo 当前的 npm 链接到这里:
    ls -al $(which npm)
    
    link_file=/usr/local/bin/node
    link_to=$(pwd)/bin/node
    if [ -f "${link_file}" -o -L "${link_file}" ]; then
        echo "删除 ${link_file}"
        sudo rm "${link_file}"
    fi
    echo "建立 ${link_file} 链接到 -> ${link_to}"
    CMD="sudo ln -s ${link_to} ${link_file}"; echo "${CMD}"; ${CMD}

    link_file=/usr/local/bin/npm
    link_to=$(pwd)/bin/npm
    if [ -f "${link_file}" -o -L "${link_file}" ]; then
        echo "删除 ${link_file}"
        sudo rm "${link_file}"
    fi
    echo "建立 ${link_file} 链接到 -> ${link_to}"
    CMD="sudo ln -s ${link_to} ${link_file}"; echo "${CMD}"; ${CMD}

    link_file=/usr/local/bin/nodejs
    link_to=$(pwd)/bin/node
    if [ -f "${link_file}" -o -L "${link_file}" ]; then
        echo "删除 ${link_file}"
        sudo rm "${link_file}"
    fi
    echo "建立 ${link_file} 链接到 -> ${link_to}"
    CMD="sudo ln -s ${link_to} ${link_file}"; echo "${CMD}"; ${CMD}
}

function update_nodejs() {
    npm install -g n
    n stable
}

# 配置淘宝 npm 镜像，解决 npm 的速度非常慢的问题【可选】
function enable_cnpm() {
    BASHRC=~/.bashrc
    if [ -n "$(grep '#alias for cnpm' ${BASHRC})" ]; then
        return 0
    fi
    echo '
#alias for cnpm
alias cnpm="npm --registry=https://registry.npm.taobao.org \
  --cache=$HOME/.npm/.cache/cnpm \
  --disturl=https://npm.taobao.org/dist \
  --userconfig=$HOME/.cnpmrc"
' >> ~/.bashrc && source ~/.bashrc
}

#apt_install
download_binary_install
enable_cnpm
