#!/bin/bash

TAR_DIR=~/Applications/android
if [ ! -d "${TAR_DIR}" ]; then
    mkdir -p "${TAR_DIR}"
fi
cd "${TAR_DIR}"

# 在中文网找到最新版本下载地址 http://www.android-studio.org/
function download() {
    URL="https://dl.google.com/dl/android/studio/ide-zips/2.3.3.0/android-studio-ide-162.4069837-linux.zip"
    wget "${URL}" -P "${TAR_DIR}"
    echo "解压缩"
    unzip *.zip
}

download
