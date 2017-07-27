#!/bin/bash

function init_global_vars() {
    RW_SHARE_DIR=~/rwShare
    RO_SHARE_DIR=~/roShare
    CONFIG_FILE=/etc/samba/smb.conf
}

function mk_sharing_dir() {
    if [ ! -d ${RW_SHARE_DIR} ]; then
        echo "创建目录(可读、可写、不可见)：${RW_SHARE_DIR}"
        mkdir ${RW_SHARE_DIR}
    fi
    if [ ! -d ${RO_SHARE_DIR} ]; then
        echo "创建目录(可见、只读、匿名)：${RO_SHARE_DIR}"
        mkdir ${RO_SHARE_DIR}
    fi
}

function install_samba() {
    echo "sudo apt-get install samba"
    sudo apt-get install samba
    return $?
}

function write_config() {
cat >> ${CONFIG_FILE} << CONFIGLINES
# Added by ${USER} for sharing file to windows. begin
[${RW_SHARE_DIR}]
    comment = the directory shared to windows. 'not browseable' & 'writeable'
    path = ${RW_SHARE_DIR}
    valid users = ${USER}
    browseable = no
    writable = yes
[${RO_SHARE_DIR}]
    comment = the directory shared to windows. 'read only' & 'guest ok'
    path = ${RO_SHARE_DIR}
    browseable = yes
    read only = yes
    guest ok = yes
# Added by ${USER} for sharing file to windows. end
CONFIGLINES
return $?
}

function config_samba() {
    local search=`grep "^\[Shared\]" ${CONFIG_FILE}`
    if [ -z "${search}" ]; then
        echo '为配置文件添加写权限'
        sudo chmod o+w ${CONFIG_FILE}
        echo '写入配置'
        write_config
        local ret=$?
        echo '取消配置文件写权限'
        sudo chmod o-w ${CONFIG_FILE}
        return ${ret}
    else
        echo '无需再次写入配置'
        return 1
    fi
}

function config_account() {
    local my_cmd ret
    my_cmd="sudo useradd ${USER}"
    echo "${my_cmd}, 添加用户${USER}"; ${my_cmd}
    if [ $? -eq 0 ]; then 
        my_cmd="sudo smbpasswd -a ${USER}"
        echo "${my_cmd}, 输入密码"; ${my_cmd}
    fi
    my_cmd="sudo service smbd restart"
    echo "${my_cmd}, 重启smb服务";     ${my_cmd}; return $?
}

function main() {
    local ret
    init_global_vars
    install_samba
    ret=$?; if [ ${ret} -ne 0 ]; then return ${ret}; fi
    mk_sharing_dir
    ret=$?; if [ ${ret} -ne 0 ]; then return ${ret}; fi
    config_samba
    ret=$?; if [ ${ret} -ne 0 ]; then return ${ret}; fi
    config_account
}

main "$@"
