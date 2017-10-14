#!/bin/bash

# Originally created by liubingzhao on 2017-07-18

# 在研项目_分配: http://by.gionee.com/issues?query_id=4393
#    17G16_分配: http://by.gionee.com/issues?query_id=4377
#    17G10_分配: http://by.gionee.com/issues?query_id=4389
#      ALL_修复: http://by.gionee.com/issues?query_id=4390 

# 配置脚本所在目录
#DIR_SCRIPTS=~/Projects/GNBJ7_TOOL_DEVELOPER/Auto_download_log
DIR_SCRIPTS=$(dirname "$0")/auto_download_log
# 配置下载到指定目录
DIR_OUT=~/roShare/Log/0-17G10
# 配置脚本文件
SCRIPT_MAIN=download_log.py

KEY_FILE="${DIR_SCRIPTS}/API_KEY"
if [ ! -f "${KEY_FILE}" ]; then
    echo "文件不存在 ${KEY_FILE}，请指定 API_KEY！"
    exit 1
else
    # 在脚本目录下的 API_KEY 文件中配置 API_KEY，KEY 通过登陆 redmine 获取
    API_KEY=$(cat "${KEY_FILE}")
fi

if [ -f "${1}" ]; then
    URL_TMP_FILE="${1}"
else
    URL_TMP_FILE=/tmp/log_url.tmp
    ${DIR_SCRIPTS}/${SCRIPT_MAIN} -a ${API_KEY} "$@" > ${URL_TMP_FILE}
    echo "已生成到文件: ${URL_TMP_FILE}"
    echo "你可以手动修改下载任务，然后手动执行: download_log.sh ${URL_TMP_FILE}"
    read -t 20
fi

COUNT=$(grep -Ev "^BUG_COUNT:|^ID:" "${URL_TMP_FILE}" | wc -l)
INDEX=1

while read line; do
    if [[ ${line} == BUG_COUNT:* ]]; then
        echo "一共发现 ${line#*:} 个 BUG"; echo
    elif [[ ${line} == ID:* ]]; then
        dir_out="${DIR_OUT}/${line#*:}"
    elif [[ ${line} == ftp://* ]]; then
        echo "开始下载第 ${INDEX}/${COUNT} 个文件"
        #echo "链接地址: ${line}"
        target_file="${dir_out}/$(basename ${line})"
        if [ -f "${target_file}" ]; then
            echo "略过！文件已存在: \"${target_file}\""; echo
            ((INDEX++))
            continue
        fi
        wget "${line}" -P "${dir_out}"
        decompress.sh "${target_file}"
        # 解压DB. BEGIN
        while read db_file; do
            if [[ ${db_file} != *.zip ]]; then
                mv "${db_file}" "${db_file}.zip"
            fi
            echo "解压db: ${db_file}"
            unzip "${db_file}.zip" -d "${db_file}.DEC"
        done < <(find "${target_file}.DEC" -name "db.*")
        # 解压DB. END
        ((INDEX++))
    fi
done < <(cat ${URL_TMP_FILE})

#if [ -f "${URL_TMP_FILE}" ]; then
#    rm ${URL_TMP_FILE}
#fi
