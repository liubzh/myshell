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
    OUT_DIR=$(dirname "$0")/apks
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

        if [[ ${line} == \#* ]]; then
            ls ${OUT_DIR}/${package_name}*.apk > /dev/null 2> /dev/null
            if [ $? -eq 0 ]; then
                echo 删除忽略的 APK ：${OUT_DIR}/${package_name}*.apk
                rm ${package_name}*.apk
            fi
            echo
            continue  # 注释掉的行略过
        fi
        
        echo "${line}"

        html_url="http://sj.qq.com/myapp/detail.htm?apkName=${package_name}"
        #echo "网页地址：${html_url}"

        apk_url=$(curl "${html_url}" | grep downUrl:)
        if [ -z "${apk_url}" ]; then
            continue
        fi

        apk_url=${apk_url#*\"}
        apk_url=${apk_url%\"*}
        echo "链接地址：${apk_url}"

        fsname=${apk_url#*fsname=}
        fsname=${fsname%.apk*}.apk
        echo "文件名：${fsname}"

        pushd ${OUT_DIR} > /dev/null
        if [ -f "${fsname}" ]; then
            echo "已是最新版本"
            echo -e "========================================================================\n"
        else
            ls ${package_name}*.apk > /dev/null 2> /dev/null
            if [ $? -eq 0 ]; then
                # 若有旧版本存在，删除旧版本
                echo 删除旧版本：${package_name}*.apk
                rm ${package_name}*.apk
            fi
            let retry=1 # 重试次数
            # 若下载失败，再重试一次
            while (( retry <= 2 )); do
                curl "${apk_url}" -o "${fsname}" --progress
                if [ $? -ne 0 ]; then
                    if [ -f "${fsname}" ]; then
                        rm "${fsname}"
                    fi
                else
                    echo
                    break
                fi
                (( retry++ ))
            done
        fi
        popd > /dev/null

    done < ${DATA_FILE}
}

main "$@"
