#!/bin/bash

OUT_DIR="$(dirname $0)/data_apks"
#PACKAGE_LIST="$(dirname $0)/packages.play.list"

while read line; do
    pkg=${line%%-*}
    echo "${pkg}"
    #if [ -n "$(grep ${pkg} ${PACKAGE_LIST})" ]; then
        apk_file="${OUT_DIR}/${pkg}.apk"
        if [ -f "${apk_file}" ]; then rm "${apk_file}"; fi
        adb pull "/data/app/${line}/base.apk" "${apk_file}"
    #fi
done < <(adb shell <<!
    su
    cd /data/app
    ls
    exit
!
)
