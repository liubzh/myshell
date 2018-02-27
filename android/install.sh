#!/bin/bash

######## Script Information. BGN ########
# Author: liubingzhao.
# Date: 2018-02-24
# Introduction: 自动为手机安装 APK
######## Script Information. END ########

function print_help() {
    cat << Help
install.sh | 从应用宝下载并安装 packages.list 中的应用程序
Usage: install.sh
Help
}

function main() {
    DATA_FILE=$(dirname "$0")/packages.list
    OUT_DIR=$(dirname "$0")/out
    if [ ! -d "${OUT_DIR}" ]; then
        mkdir "${OUT_DIR}"
    fi
    local package_name
    local html_url
    local apk_url
    local fsname
    local apk_out_path
    while read line; do

        package_name="${line#*:}"
        package_name="${package_name#* }"
        echo "PACKAGE INFO: ${line}"

        html_url="http://sj.qq.com/myapp/detail.htm?apkName=${package_name}"
        echo "APP PAGE URL: ${html_url}"

        apk_url=$(curl "${html_url}" | grep downUrl:)
        apk_url=${apk_url#*\"}
        apk_url=${apk_url%\"*}
        echo "APK URL: ${apk_url}"

        fsname=${apk_url#*fsname=}
        fsname=${fsname%.apk*}.apk
        echo "FILE NAME: ${fsname}"

        pushd ${OUT_DIR} > /dev/null
        if [ -f "${fsname}" ]; then
            echo "已是最新版本"
            echo -e "========================================================================\n"
        else
            ls ${package_name}*.apk > /dev/null 2> /dev/null
            if [ $? -eq 0 ]; then
                # 若有旧版本存在，删除旧版本
                echo REMOVE OLD VERSION: ${package_name}*.apk
                rm ${package_name}*.apk
            fi
            let retry=1
            # 若下载失败，再重试一次
            while (( retry <= 2 )); do
                curl "${apk_url}" -o "${fsname}" --progress
                if [ $? -ne 0 ]; then
                    if [ -f "${fsname}" ]; then
                        rm "${fsname}"
                    fi
                else
                    break
                fi
                (( retry++ ))
            done
        fi
        popd > /dev/null

    done < ${DATA_FILE}
}

main "$@"
