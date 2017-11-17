#!/bin/bash

TAR_DIR=~/Applications/bcompare
if [ ! -d "${TAR_DIR}" ]; then
    mkdir -p "${TAR_DIR}"
fi
cd "${TAR_DIR}"
    
BCOMPARE_DIR="/Applications/Beyond Compare.app/Contents/MacOS"
BCOMPARE_EXE="${BCOMPARE_DIR}/BCompare"
BCOMP_EXE="${BCOMPARE_DIR}/bcomp"
BCOMPARE_REGISTRY="~/Library/Application Support/Beyond Compare/registry.dat"

function download_file() {
    # 找到对应操作系统的最新版本下载地址：http://www.scootersoftware.com/download.php
    # 记录笔记时最新版本链接如下：
    URL="http://www.scootersoftware.com/BCompareOSX-4.2.3.22587.zip"
    wget "${URL}" -P "${TAR_DIR}"
    echo "解压缩 zip"
    tar -xzvf *.zip
}

function gen_scripts() {
    if [ ! -f "${BCOMPARE_EXE}.real" ]; then
        echo "移动文件： BCompare -> BCompare.real"
        mv "${BCOMPARE_EXE}" "${BCOMPARE_EXE}.real"
        echo "写入文件：'${BCOMPARE_EXE}'"
        echo '#!/bin/bash' > "${BCOMPARE_EXE}"
        echo 'rm "/Users/$(whoami)/Library/Application Support/Beyond Compare/registry.dat"' >> "${BCOMPARE_EXE}"
        echo '"$(dirname "$0")"/BCompare.real "$@"' >> "${BCOMPARE_EXE}"
        chmod +x "${BCOMPARE_EXE}"
    else
        echo "文件已存在：'${BCOMPARE_EXE}'"
    fi

    if [ ! -f "${BCOMP_EXE}.real" ]; then
        echo "移动文件： bcomp -> bcomp.real"
        mv "${BCOMP_EXE}" "${BCOMP_EXE}.real"
        echo "写入文件：'${BCOMP_EXE}'"
        echo '#!/bin/bash' > "${BCOMP_EXE}"
        echo 'rm "/Users/$(whoami)/Library/Application Support/Beyond Compare/registry.dat"' >> "${BCOMP_EXE}"
        echo '"$(dirname "$0")"/bcomp.real "$@"' >> "${BCOMP_EXE}"
        chmod +x "${BCOMP_EXE}"
    else
        echo "文件已存在：'${BCOMP_EXE}'"
    fi
}

function check_script() {
    # 这个方法中的操作主要为解决30天试用期问题
    if [ -d "${BCOMPARE_DIR}" ]; then
        gen_scripts
    else
        echo "Beyond Compare.app 目录不存在，可能尚未安装此程序"
    fi
}

#Step1: 下载文件
#download_file
#Step2: 手动安装
#Step3: 添加脚本
check_script
