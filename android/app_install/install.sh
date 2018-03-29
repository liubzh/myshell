#!/bin/bash

function main() {
    OUT_DIR=$(dirname "$0")/apks
    if [ ! -d "${OUT_DIR}" ]; then
        return 1
    fi
    local package_name
    local version_name
    local version_code
    local ver_code
    for item in $(ls ${OUT_DIR}); do
        package_name=${item%%_*}
        version_code=${item%.apk*}
        version_code=${version_code##*_}
        ver_code=$(adb shell dumpsys package ${package_name} | grep -i versionCode)
        ver_code=${ver_code#*=}
        ver_code=${ver_code%% *}
        echo "应用包名：${package_name}"
        if [[ ${version_code} == ${ver_code} ]]; then
            echo "已安装最新版本"
        else
            echo "安装或升级：${ver_code} --> ${version_code}"
            adb install -r ${OUT_DIR}/${item}
        fi
    done
}

main "$@"
