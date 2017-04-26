#!/bin/bash

function check_fastboot() {
    if [ -z "`fastboot devices`" ]; then
        adb reboot bootloader
        if [ $? -ne 0 ]; then
            echo "未找到可用设备，如已连接，请确认是否处于 FASTBOOT | ADB 模式"
            exit 1
        fi
    fi
}

function flash_bp() {
    fastboot flash modem NON-HLOS.bin
    fastboot flash sbl1 sbl1.mbn
    fastboot flash sbl1bak sbl1.mbn
    fastboot flash rpm  rpm.mbn
    fastboot flash rpmbak rpm.mbn
    fastboot flash tz tz.mbn
    fastboot flash tzbak tz.mbn
    fastboot flash devcfg devcfg.mbn
    fastboot flash devcfgbak devcfg.mbn
}

function flash_ap() {
    fastboot flash dsp adspso.bin
    fastboot flash aboot emmc_appsboot.mbn
    fastboot flash abootbak emmc_appsboot.mbn
    fastboot flash boot  boot.img
    fastboot flash recovery recovery.img
    fastboot flash system system.img
    fastboot flash cache cache.img
    fastboot flash persist persist.img
    fastboot flash mdtp mdtp.img

    fastboot flash cmnlib cmnlib.mbn
    fastboot flash cmnlibbak cmnlib.mbn

    fastboot flash cmnlib64 cmnlib64.mbn
    fastboot flash cmnlib64bak cmnlib64.mbn
    fastboot flash keymaster keymaster.mbn
    fastboot flash keymasterbak  keymaster.mbn
    fastboot flash splash splash.img
    fastboot flash userdata userdata.img
}

function main() {
    check_fastboot
    if [ -z "$1" ]; then
        echo "全烧"
        flash_bp
        flash_ap
    elif [[ $1 == -b || $1 == --bp ]]; then
        echo "只烧BP"
        flash_bp
    elif [[ $1 == -a || $1 == --ap ]]; then
        echo "只烧AP"
        flash_ap
    fi
    fastboot reboot
}

main "$@"
