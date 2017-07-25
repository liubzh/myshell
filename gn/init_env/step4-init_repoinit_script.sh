#!/bin/bash

BIN_DIR=~/bin
TARGET_FILE=./repo_repoinit_conf
RC_FILE=~/.bashrc

if [ ! -d "${BIN_DIR}" ]; then
    mkdir "${BIN_DIR}"
fi

if [ -f "${TARGET_FILE}" ]; then
    cp -v "${TARGET_FILE}" "${BIN_DIR}"
    echo "添加可执行权限"
    chmod +x "${BIN_DIR}/${TARGET_FILE}"
    CONTENT="export PATH=${BIN_DIR}:\$PATH"
    SEARCH=`grep "${CONTENT}" ${RC_FILE}`
    if [ -z "${SEARCH}" ]; then 
        echo "${CONTENT}" >> "${RC_FILE}"
        echo "写入环境变量"
    else
        echo "如下环境变量已配置,无需再次写入"
        echo "${CONTENT}"
    fi
fi
