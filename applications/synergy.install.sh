#!/bin/bash

TAR_DIR=~/Applications
if [ ! -d "${TAR_DIR}" ]; then
    mkdir -p "${TAR_DIR}"
fi
cd "${TAR_DIR}"

# 更多信息：https://github.com/symless/synergy/wiki
# 编译文档：https://github.com/symless/synergy/wiki/Compiling

# 通过下载源码安装
function git_clone() {
    git clone https://github.com/symless/synergy-core.git
    cd synergy
    # 建立分支
    git tag
    git branch mytag-v1.8.8-stable v1.8.8-stable
    git checkout mytag-v1.8.8-stable
}

function install_dependencies() {
    sudo apt-get install cmake make g++ xorg-dev libqt4-dev libcurl4-openssl-dev libavahi-compat-libdnssd-dev libssl-dev libx11-dev
}

function do_compile() {
    # optionally add '-d' to build a debug version.
    QT_SELECT=4 ./hm.sh conf -g1 
    ./hm.sh build
    # optionally build a package if you wish to install it system-wide with a package manager instead of running from the cli
    ./hm.sh package deb
    sudo dpkg -i ./bin/synergy-master-stable-ec56ac4-Linux-x86_64.deb
}

git_clone
install_dependencies
do_compile
