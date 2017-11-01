#!/bin/bash

######## Script Information. BGN ########
# Author: liubingzhao.
# Date: 2017-01-03
######## Script Information. END ########

PROJECTS_ROOT="${MYPROJECTDIR}"
TARGET_SH=${PROJECTS_ROOT}/task.sh
TARGET_LOG=${PROJECTS_ROOT}/task.log
proj_dir=
project=
product=
branch=
tag=
local_branch=
local_tag_branch=
recompile_tag=
compile_only=false

function print_help() {
    cat << Help
用法：new-task.sh [OPTIONS]
Options:
  <-d|--directory> :    指定项目目录，如 G1602A、G1602A_ 等
  <-p|--project>   :    指定项目名称，如 G1602A、G1605A、BBL7515A 等
  <-P|--product>   :    指定产品名称，如 G1601A、G1602A_sign、G1602A_platform 等
  <-b|--branch>    :    指定分支名称，如 origin/code_main_dev、origin/gbl8918_code_main_dev 等
  [-t|--tag]       :    指定TAG名称，如 G1602A-T0144-170424AA、G1602A-T0110-170401AA_PATCH 等
  [-r|--recompile] :    指定编译失败以后需要切换的TAG名称，同 --tag
Example:
  new-task.sh -d=G1602A_ -p=G1602A -P=G1602A_platform -b=origin/code_main_dev
Help
}

# 解析并验证参数
# return 0: ok
# return 1: print help.
function parse_and_check_args () {
    while [ $# -gt 0 ];do
        case "$1" in
            -h|--help|\?)
                print_help
                return 1    # exit.
                ;;
            -d*|--directory*)
                proj_dir=${PROJECTS_ROOT}/${1#*=}
                echo directory=${proj_dir}
                shift
                ;;
            -p*|--project*)
                project=${1#*=}
                echo project=${project}
                shift
                ;;
            -P*|--product*)
                product=${1#*=}
                echo product=${product}
                shift
                ;;
            -b*|--branch*)
                branch=${1#*=}
                local_branch="mybranch-${branch##*/}"
                echo branch=${branch}
                echo local_branch=${local_branch}
                shift
                ;;
            -t*|--tag*)
                tag=${1#*=}
                local_tag_branch=mytag-${tag}
                echo tag=${tag}
                echo local_tag_branch=${local_tag_branch}
                shift
                ;;
            -r*|--recompile*)
                recompile_tag=${1#*=}
                echo recompile_tag=${recompile_tag}
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    if [ -z "${proj_dir}" ]; then
        echo "proj_dir为空，请指定 -d|--directory=xxx"
        return 1
    fi
    if [ -z "${project}" ]; then
        echo "project为空，请指定 -p|--project=xxx"
        return 1
    fi
    if [ -z "${product}" ]; then
        echo "product为空，请指定 -P|--product=xxx"
        return 1
    fi
    if [ -z "${branch}" ]; then
        echo "branch为空，请指定 -b|--branch=xxx"
        return 1
    fi
}

function genFunctions() {
    if [ -s "${TARGET_SH}" ]; then
        #read -p "目标文件 ${TARGET_SH} 存在且不为空，删除吗?(y/n/直接回车追加):" ANSWER
        #if [[ ${ANSWER} == Y || ${ANSWER} == y ]]; then
        #    rm ${TARGET_SH}
        #else
            return 0
        #fi
    fi
    cat > "${TARGET_SH}" << 'CODE'
#!/bin/bash

# 计算两个时间点之间的时长
# <$1> <$2>: 以秒为单位的时间点，可使用 $(date +%s) 获取时间
function getDuration() {
    local duration=$(($1-$2))
    if ((${duration} < 0)); then
        duration=$((-${duration}))
    fi
    local h=$((duration/3600))
    local m=$((duration%3600/60))
    local s=$((duration%60))
    printf %02d:%02d:%02d ${h} ${m} ${s}
}

function getTimestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

# 执行命令函数
# [$1]: [-n|--no-echo]: 如果指定参数-n|--no-echo，则输出到/dev/null
function exeCMD() {
    local no_echo=false
    local mycmd="$@"
    if [[ $1 == -n || $1 == --no-echo ]]; then
        mycmd="${@: 2}"
        no_echo=true
    fi
    echo "执行命令: ${mycmd}"                      | tee -a ${LOG_FILE}
    echo "  时间戳: $(getTimestamp)"                     >> ${LOG_FILE}
    local t_start=$(date +%s)
    # ------执行命令-始------
    local ret
    if ${no_echo}; then
        ${mycmd} > /dev/null
    else
        ${mycmd}
    fi
    ret=$?
    # ------执行命令-终------
    echo "    结果: "${ret}                              >> ${LOG_FILE}
    local t_end=$(date +%s)
    echo "    耗时: $(getDuration ${t_start} ${t_end})"  >> ${LOG_FILE}
    return ${ret}
}

# $1: 分支或者是TAG
function doCheckout() {
    exeCMD -n repo forall -pc git clean -df
    exeCMD repo forall -pc git checkout .
    exeCMD -n repo forall -pc git fetch

    local is_branch=$(git branch -r | grep "${1}")
    local is_tag=$(git tag | grep "${1}")

    local local_branch=
    local remote_branch_or_tag=
    if [ -n "${is_branch}" ]; then
        # ----- BRANCH -----
        remote_branch_or_tag=${1}
        local_branch="mybranch-${remote_branch_or_tag##*/}"
    elif [ -n "${is_tag}" ]; then
        # ----- TAG -----
        remote_branch_or_tag=${1}
        local_branch=mytag-${remote_branch_or_tag}
    fi

    if [ -n "${local_branch}" ]; then
        local search_branch=$(git branch | grep "${local_branch}")
        if [ -n "${search_branch}" ]; then
            # 本地分支存在，切换到目标分支，更新到最新
            exeCMD -n repo forall -pc git branch temp-branch ${remote_branch_or_tag}
            exeCMD -n repo forall -pc git checkout temp-branch
            exeCMD repo forall -pc git branch -D ${local_branch}
            exeCMD repo forall -pc git branch ${local_branch} ${remote_branch_or_tag}
            exeCMD -n repo forall -pc git checkout ${local_branch}
            exeCMD repo forall -pc git branch -D temp-branch
        else
            # 如果本地分支不存在，直接创建并更新代码
            exeCMD repo forall -pc git branch ${local_branch} ${remote_branch_or_tag}
            exeCMD repo forall -pc git checkout ${local_branch}
        fi
    fi
}

function doCompile() {
    local project=${1}
    local product=${2}
    local compile_type=${3}  # <user|eng>
    local recompile=${4}  # [-r] switch to latest tag and recompile when fail.
    local tag=${5} # the TAG you want to recompile on. depends on [-r]

    local compile_cmd="./TmakeGionee -t ${product} -n"
    if [[ ${compile_type} == user ]]; then
        compile_cmd="./TmakeGionee -v user ${product} -n"
    fi

    exeCMD ${compile_cmd}
    local ret=$?
    if [ ${ret} -eq 0 ]; then
        local RELEASE_DIR=release
        local last_release=`ls ${RELEASE_DIR} -t |head -n1`
        exeCMD mv ${RELEASE_DIR}/${last_release} ${RELEASE_DIR}/${last_release}_${compile_type}
    elif [[ ${recompile} == -r ]]; then
        if [ -n "${tag}" ]; then
            #SUCCESSFUL=`tail -n3 BUILDING_LOG/*-android.log |grep "make completed successfully"`
            #if [ -z "${SUCCESSFUL}" ]; then
                echo 没编译成功，切换到给定Tag重新编译 | tee -a ${LOG_FILE}
                #local to_tag=`git tag | grep ^${MY_GN_PROJ}- | grep -v _PATCH | tail -n1`
                local to_tag=${tag}
                doCheckout ${to_tag}
                exeCMD ${compile_cmd}
            #fi
        fi
    fi
}

function doShutdown() {
    exeCMD sudo shutdown -h now
}

CODE
    cat >> ${TARGET_SH} << CODE
function defineGlobalVars() {
    LOG_FILE=${TARGET_LOG}
}

defineGlobalVars

CODE
}

function checkDirExport() {
    if [ ! -d ${proj_dir} ]; then
        mkdir ${proj_dir}
    fi
    local export_sh=${proj_dir}/export.sh
    touch ${export_sh}
    local tmp_sh=/tmp/export.sh
    echo "export MY_GN_PROJDIR=${proj_dir}" > ${tmp_sh}
    echo "export MY_GN_PROJ=${project}"    >> ${tmp_sh}
    echo "export MY_GN_PROD=${product}"    >> ${tmp_sh}
    diff ${tmp_sh} ${export_sh} > /dev/null
    if [ $? -ne 0 ]; then
        if [ -s ${export_sh} ]; then
            echo "原有内容："
            cat ${export_sh}
        fi
        echo "目标内容："
        cat ${tmp_sh}
        read -p "替换吗? (y/n)" ANSWER
        if [[ ${ANSWER} == y || ${ANSWER} == Y ]]; then
            cp ${tmp_sh} ${export_sh}
            chmod +x ${export_sh}
        else
            echo "未能生成任务"
          return 1
        fi
    fi
}

function genTaskHeader() {
    echo 'echo                                     >> ${LOG_FILE}'       >> ${TARGET_SH}
    echo 'echo ------任务开始时间: $(getTimestamp)------ \'              >> ${TARGET_SH}
    echo '                                   | tee -a ${LOG_FILE}'       >> ${TARGET_SH}
    echo '# 你想删除某个目录吗? 可以写在下边.'                           >> ${TARGET_SH}
    echo '#rm -rf dir'                                                   >> ${TARGET_SH}
    echo "exeCMD cd ${proj_dir}"                                         >> ${TARGET_SH}
    echo 'exeCMD source export.sh'                                       >> ${TARGET_SH}
    echo 'time_START=$(date +%s)'                                        >> ${TARGET_SH}
}

function genTaskFooter() {
    echo 'time_END=$(date +%s)'                                          >> ${TARGET_SH}
    echo 'echo ------任务结束时间: $(getTimestamp)------ \'              >> ${TARGET_SH}
    echo '                                   | tee -a ${LOG_FILE}'       >> ${TARGET_SH}
    echo 'echo ------任务总共耗时: $(getDuration ${time_START} ${time_END})------ | tee -a ${LOG_FILE}' >> ${TARGET_SH}

    # 删除所有关机的命令, 并确认是否执行完后关机
    sed -i '/^doShutdown*/d' ${TARGET_SH}
    #read -p "执行完后关机吗? (y/n)" ANSWER
    #if [[ ${ANSWER} == y || ${ANSWER} == Y ]]; then
    #    echo 'doShutdown'                                                >> ${TARGET_SH}
    #fi
    echo 'doShutdown'                                                >> ${TARGET_SH}

    chmod +x ${TARGET_SH}
    #read -p "已写入${TARGET_SH}, 查看此文件吗? (y/n)" ANSWER
    #if [[ ${ANSWER} == y || ${ANSWER} == Y  ]]; then
    #    vim ${TARGET_SH}
    #fi
    echo "已写入 ${TARGET_SH}"
    #echo "现在可以执行此脚本,或source这个脚本了."
}

function genTask() {
    local isNewDir=true
    for item in ${proj_dir}/*; do
        if [[ ${item} != */export.sh ]]; then
            isNewDir=false
            break
        fi
    done


    # 如果目录为空，则执行repo_sync脚本下载代码。
    if ${isNewDir}; then
        echo 'exeCMD repo_repoinit_conf'                                 >> ${TARGET_SH}
    fi
    echo 'exeCMD cd L*/android*'                                         >> ${TARGET_SH}

    read -p "若想直接编译，输入编译类型 user|eng (回车跳过)：" ANSWER
    if [[ ${ANSWER} == user || ${ANSWER} == usr ]]; then
        echo "doCompile ${project} ${product} user"                      >> ${TARGET_SH}
        return 0
    else
        echo "doCompile ${project} ${product} eng"                       >> ${TARGET_SH}
        return 0
    fi

    if [ -n "${branch}" ]; then
        echo "doCheckout ${branch}"                                          >> ${TARGET_SH}
    fi
    if [ -n "${local_tag_branch}" ]; then
        echo "doCheckout ${local_tag_branch}"                                >> ${TARGET_SH}
    fi

    read -p "编译User版本? (y/n)" ANSWER
    if [[ ${ANSWER} == y || ${ANSWER} == Y ]]; then
        if [ -n "${recompile_tag}" ]; then
            echo "doCompile ${project} ${product} user -r ${recompile_tag}"  >> ${TARGET_SH}
        else
            echo "doCompile ${project} ${product} user"                      >> ${TARGET_SH}
        fi
    fi

    if [ -n "${recompile_tag}" ]; then
        echo "doCompile ${project} ${product} eng -r ${recompile_tag}"       >> ${TARGET_SH}
    else
        echo "doCompile ${project} ${product} eng"                           >> ${TARGET_SH}
    fi
}

function main() {
    parse_and_check_args "$@"
    case "$?" in
    1)
        return 1
        ;;
    esac
    genFunctions
    checkDirExport
    case "$?" in
    1)
        return 1
        ;;
    esac
    genTaskHeader
    genTask
    genTaskFooter
}

main "$@"
