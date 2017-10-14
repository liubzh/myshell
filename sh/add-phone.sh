#!/bin/bash

######## Script Information. BGN ########
# Author: liubingzhao.
# Date: 2016-01-12
######## Script Information. END ########

# All the global variables in this script.
function init_global_variables() {
    TARGET_LINE=
    idVendor=
    idProduct=
    TARGET=/etc/udev/rules.d/51-android.rules
    CONTENT=
}

function print_help() {
    cat << Help
add-phone.sh
添加 USB 设备访问权限到文件 '/etc/udev/rules.d/51-android.rules'
当没有设备的访问权限的时候，需要配置设备信息时，此脚本可帮助你完成配置。
Help
}

# Parse and validate the arguments.
# return 0: ok
# return 1: print help.
function parse_and_check_args () {
    while [ $# -gt 0 ];do
        case "$1" in
            -h|--help|\?)
                print_help
                exit 0
                ;;
            *)
                shift
                ;;
        esac
    done
}

# use 'diff' command to gather usb device infomation.
function gather_info() {
    local lsusb_pluged=/tmp/lsusb_pluged
    local lsusb_unpluged=/tmp/lsusb_unpluged
    local lsusb_diff=/tmp/lsusb_diff

    read -p "请先拔下 USB 设备，然后按回车键继续..."
    lsusb > $lsusb_unpluged
    read -p "请再插入 USB 设备，然后按回车键继续..."
    lsusb > $lsusb_pluged
    diff $lsusb_pluged $lsusb_unpluged > $lsusb_diff
    while read line; do
        if [[ $line == \<* ]]; then
            TARGET_LINE=${line#* ID }
            echo "设备信息： ${TARGET_LINE}"
        fi
    done < $lsusb_diff
}

function cut_string() {
    TARGET_LINE=${TARGET_LINE#* ID }
    TARGET_LINE=${TARGET_LINE:0:9}
    idVendor=`echo $TARGET_LINE|awk -F ":" '{print $1}'`
    idProduct=`echo $TARGET_LINE|awk -F ":" '{print $2}'`
}

function main() {
    init_global_variables

    parse_and_check_args "$@"

    gather_info
    if [ -z "${TARGET_LINE}" ]; then
        echo "没有捕捉到设备信息"
        return 1
    fi
    cut_string
    CONTENT="SUBSYSTEM==\"usb\", ATTR{idVendor}==\"${idVendor}\", ATTR{idProduct}==\"${idProduct}\", MODE=\"0600\", OWNER=\"${USER}\""
    if [ -n "$(grep ${idVendor} ${TARGET}|grep ${idProduct}|grep ${USER})" ]; then
        echo "无需配置，已有权访问设备 ${idVendor}:${idProduct}"
        echo "如果你仍无法访问设备，重新插拔设备试试"
        return 0
    fi
    echo "[${CONTENT}]"
    echo "由于 '${TARGET}' 的文件权限问题，需要使用 sudo 完成写入操作"
    sudo chmod 666 "${TARGET}"
    echo "${CONTENT}" >> "${TARGET}"
    if [ $? -eq 0 ]; then
        echo "已成功写入"
    fi
    sudo chmod 644 "${TARGET}"
    echo "请重新插拔 USB 设备使配置生效"
}

main "$@"
