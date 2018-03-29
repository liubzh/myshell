#!/bin/bash

######## Script Information. BGN ########
# Author: liubingzhao.
# Date: 2017-12-11
######## Script Information. END ########

# Error code:
# 1
# 2
# 3

# All the global variables in this script.
function init_global_variables() {
    USER_NAME=liubingzhao
    OPERATION=
}

function print_help() {
    cat << Help
clone.sh
  代码克隆汇总脚本，免去记忆地址、命令的困扰。
Help
}

function project_list() {
    echo "deskclock     : git clone ssh://${USER_NAME}@git.xgrobotics.com:29418/puppy/deskclock"
    echo "homecontrol   : git clone ssh://${USER_NAME}@git.xgrobotics.com:29418/puppy/homecontrol"
    echo "plugindev     : git clone ssh://${USER_NAME}@git.xgrobotics.com:29418/puppy/plugindev"
    echo "puppylauncher : git clone ssh://${USER_NAME}@git.xgrobotics.com:29418/puppy/puppylauncher"
    echo "puppyai       : git clone ssh://${USER_NAME}@git.xgrobotics.com:29418/puppy/puppyai"
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
            clone)
                OPERATION=clone
                shift
                ;;
            push)
                OPERATION=push
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    if [ -z "${OPERATION}" ]; then
        echo "没啥可做的，你没指定操作，如：clone, push"
        exit 5
    fi
}

# 判断当前 git 命令是否可用
function check_git_installed() {
    if [ -z "$(which git)" ]; then
        echo "你还没安装 git ！"
        exit 3
    fi
}

# 此方法判断当前 git 目录下的 config 中 user.email 是否满足要求
function check_git_config() {
    local line email name
    while read line; do
        if [[ ${line} == user.email=* ]]; then
            email="${line#*=}"
        elif [[ ${line} == user.name=* ]]; then
            name="${line#*=}"
        fi
    done < <(git config -l)
    echo "user.name=${name}"
    echo "user.email=${email}"
    if [[ ${email} != *xgrobotics.com* ]]; then
        echo "配置的邮箱不是小狗信箱！"
        exit 2
    fi
}

function pick_project_and_clone() {
    local line projects item
    while read line; do
        line="${line%% : *}"
        if [ -z "${projects}" ]; then
            projects="${line}"
        else
            projects="${projects} ${line}"
        fi
    done < <(project_list)
    select item in ${projects}; do
        echo "${item}"
        break
    done
    # do clone
    local cmd=$(project_list | grep "${item}")
    cmd=${cmd#* : }
    ${cmd}
    local result=$?
    if [ ${result} -eq 0 ]; then
        cd "${item}"
        scp -p -P 29418 ${USER_NAME}@git.xgrobotics.com:hooks/commit-msg .git/hooks/; chmod +x .git/hooks/commit-msg
    fi
}

function push() {
    local url=$(git config -l | grep "^remote.origin.url")
    local project_name=${url##*/}
    echo "project_name=${project_name}"
    #local cmd="git push ssh://${USER_NAME}@git.xgrobotics.com:29418/puppy/${project_name} HEAD:refs/for/master"
    local cmd="git push ${url#*url=} HEAD:refs/for/master"
    echo "${cmd}"
    read -p "确定执行以上操作吗？回车继续..."
    ${cmd}
}

function main() {
    init_global_variables
    parse_and_check_args "$@"
    check_git_installed
    check_git_config
    if [[ ${OPERATION} == clone ]]; then
        pick_project_and_clone
    elif [[ ${OPERATION} == push ]]; then
        push
    fi
}

main "$@"
