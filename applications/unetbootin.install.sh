#!/bin/bash

# 制作U盘启动镜像
function install() {
    sudo apt-get install unetbootin
}

function uninstall() {
    # 卸载
    sudo apt-get remove bcompare
}

function write_image() {
    # 格式化u盘
    local tmp=/tmp/fdisks
    sudo fdisk -l | tee "${tmp}"

    echo -e "\n从以上信息中检索到以下磁盘："
    local fdisks=
    while read line; do
        if [[ ${line} == Disk* || ${line} == /dev/* ]]; then
            echo "${line}"
            if [[ ${line} == /dev* ]]; then
                fdisks="${line%% *} ${fdisks}"
            fi
        fi
    done < "${tmp}"
    rm "${tmp}"

    echo -e "\n确认盘符(一定要谨慎选择，选错小心丢失全部数据)："
    local item=
    while [ -z "${item}" ]; do
        select item in ${fdisks}; do
            echo ${item}
            break
        done
    done
    item=${item%%:*}

    echo
    read -p "即将格式化U盘 '${item}'? (y/n)" ANSWER
    if [[ ${ANSWER} == y || ${ANSWER} == Y ]]; then
        echo "卸载U盘 ${item}"
        sudo umount "${item}"
        echo "格式化U盘 ${item} 为fat32格式"
        sudo mkfs.vfat "${item}"
    fi
}

#install
#uninstall
write_image
