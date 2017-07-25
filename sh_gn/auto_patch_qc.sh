#!/bin/bash

# liubingzhao modified on 2017-3-24
# for autopatch

MTK_ANDROID_PATH=`pwd`
MTK_PACKAGES_NAME=""
MTK_PATCH_PATH=""
MTK_PACKAGES_DIR_FLAG="FALSE"

PATCH_BUILD_VERNO=""
PATCH_WEEK_NO=""

DIFF_PATH=~/mydiff
ANDROID_DIFF_PATH=${DIFF_PATH}/android
PACKAGES_DIFF_PATH=${DIFF_PATH}/packages
ANDROID_DIFF_LIST=${DIFF_PATH}/android.list
PACKAGES_DIFF_LIST=${DIFF_PATH}/packages.list
SO_LIST=${DIFF_PATH}/so.list
JAR_LIST=${DIFF_PATH}/jar.list
SUCCESS_LIST=${DIFF_PATH}/success.list
FAIL_LIST=${DIFF_PATH}/fail.list
IGNORE_LIST=${DIFF_PATH}/ignore.list
SAME_LIST=${DIFF_PATH}/same.list
BINARY_LIST=${DIFF_PATH}/binary.list
DELETE_GN_LIST=${DIFF_PATH}/delete_gn.list
DELETEED_GN_LIST=${DIFF_PATH}/deleted_gn.list

#用于保存 repo 库中所有子库的路径
ARR_REPO_PROJECT_LIST=("")

# color output style start
# \033[显示方式;前景色;背景色m
# 显示方式:0（默认值）、1（高亮）、22（非粗体）、4（下划线）、24（非下划线）、5（闪烁）、25（非闪烁）、7（反显）、27（非反显）
# 前景色:30（黑色）、31（红色）、32（绿色）、 33（黄色）、34（蓝色）、35（洋红）、36（青色）、37（白色）
# 背景色:40（黑色）、41（红色）、42（绿色）、 43（黄色）、44（蓝色）、45（洋红）、46（青色）、47（白色）
# \033[0m 默认
# \033[1;32;40m 绿色
# 033[1;31;40m 红色
COLOR_ERROR_PREFIX='\033[1;31;48m [ERROR]'
COLOR_WARNING_PREFIX='\033[1;33;48m [WARNING]'
COLOR_SUCCESS_PREFIX='\033[1;32;48m [SUCCESS]'
COLOR_GREEN_PREFIX='\033[1;32;48m'
COLOR_SUFFIX='\033[0m'
# color output style end


#===================================================================
#获取 repo 库中所有子库的路径
#===================================================================
function countRepoProjectList()
{
    local i=0
    local repoProjectListPatch="repo_project_list.txt"
    repo info | grep "Mount path: " > $repoProjectListPatch
    while read line
    do
        ARR_REPO_PROJECT_LIST[i]=$(echo $line | awk -F "Mount path: " '{printf("%s", $2)}')
        i=$(($i + 1))
    done < $repoProjectListPatch
    rm $repoProjectListPatch
}

#在每个git库中执行git命令，为了解决repo命令会暂停（暂停会导致自动化编译不能进行）的问题。
function runGitCommondInPerProject()
{
    for projects in ${ARR_REPO_PROJECT_LIST[*]}
    do
        pushd ${projects} >/dev/null
        if [[ -n $(echo $1 | grep 'reset HEAD') || -n $(echo $1 | grep 'clean -dfx') ]];then
            echo "in $projects run git commond:"
            echo -e "${COLOR_GREEN_PREFIX}[$1 >/dev/null]${COLOR_SUFFIX}"
            $1 >/dev/null
        else
            echo "in ${projects} run git commond:"
            echo -e "${COLOR_GREEN_PREFIX}[$1]${COLOR_SUFFIX}"
            $1
        fi
        local ret=$?
        popd >/dev/null
        if [ $ret -ne 0 ]; then
            return $ret
        fi
    done
}

function runRepoCommond()
{
    if [[ $IS_REPO = "YES" ]];then
        runGitCommondInPerProject "$1"
    else
        if [[ -n $(echo $1 | grep 'reset HEAD') || -n $(echo $1 | grep 'clean -dfx') ]];then
            echo "$1 >/dev/null"
            $1 >/dev/null
        else
            echo "$1"
            $1
        fi
    fi
    return $?
}

function initLocalVar()
{
    #MTK_PATCH_PATH=$1
    #if [[ -z ${MTK_PATCH_PATH} || ! -e ${MTK_PATCH_PATH} ]];then
    #    echo -e "${COLOR_ERROR_PREFIX} Dir ${MTK_PATCH_PATH} is not exsit!${COLOR_SUFFIX}"
    #    exit 1
    #fi
    local localPackagePath=$(ls ../ | grep "packages")
    MTK_PACKAGES_NAME="${MTK_ANDROID_PATH}/../${localPackagePath}"
}

function checkDeleteFileFromPatch()
{
    echo "function checkDeleteFileFromPatch"
    pushd ${MTK_PATCH_PATH} >/dev/null
    local isDeleteFlag="FALSE"
    while read line
    do
        local result=$(grep -R "delete" ${line})
        if [[ -n ${result} ]];then
            echo -e "${COLOR_WARNING_PREFIX} 注意，当前 Patch 有删除的文件，请手动处理！ ${COLOR_SUFFIX}"
            echo -e "${COLOR_GREEN_PREFIX} ${result} ${COLOR_SUFFIX}"
            isDeleteFlag="TRUE"
            break
        fi
    done < <(find . -maxdepth 1 -type f)
    if [ "${isDeleteFlag}" = "TRUE" ];then
        #打开一个新的终端，在新的窗口中处理错误
        pushd ${MTK_ANDROID_PATH} >/dev/null
        gnome-terminal
        read -p "请在新窗口中处理完错误之后，回车键将继续执行...."
        popd >/dev/null
    fi
    popd >/dev/null
}

function getBuildVernoFromPatch()
{
    echo "function getBuildVernoFromPatch [$1]"
    #get build version number from patch
    pushd ${MTK_PATCH_PATH} >/dev/null
    local mtkProjectConfig="alps/device/gionee_bj/$1/ProjectConfig.mk"
    if [ ! -e ${mtkProjectConfig} ];then
        echo -e "${COLOR_ERROR_PREFIX} 当前不存在 ProjectConfig.mk! ${COLOR_SUFFIX}"
        exit 1
    fi
    local tmpWeekNo=$(grep "MTK_WEEK_NO" ${mtkProjectConfig} | awk -F '=' '{printf("%s",$2)}' | sed s/[[:space:]]//g)
    local tmpBuildNo=$(grep "MTK_BUILD_VERNO" ${mtkProjectConfig} | awk -F '=' '{printf("%s",$2)}' | sed s/[[:space:]]//g)
    if [[ -z ${tmpWeekNo} || -z ${tmpBuildNo} ]];then
        exit 1
    fi
    PATCH_BUILD_VERNO=${tmpBuildNo}
    PATCH_WEEK_NO=${tmpWeekNo}

    echo -e "${COLOR_GREEN_PREFIX} PATCH_BUILD_VERNO:[${PATCH_BUILD_VERNO}],PATCH_WEEK_NO:[${PATCH_WEEK_NO}]${COLOR_SUFFIX}"
    popd >/dev/null
}

function copyAndroidDir()
{
    echo "function copyAndroidDir"
    if [ ! -e ${MTK_PATCH_PATH} ];then
        echo -e "${COLOR_ERROR_PREFIX} Dir ${MTK_PATCH_PATH} does not exsit!${COLOR_SUFFIX}"
        exit 1
    fi
    pushd ${MTK_PATCH_PATH} >/dev/null
    while read line
    do
        if [ "${line}" = "packages" ];then
            MTK_PACKAGES_DIR_FLAG="TRUE"
            echo -e "${COLOR_WARNING_PREFIX} 注意，当前 Patch 有 Packages！ ${COLOR_SUFFIX}"
            continue
        fi
        echo "cp -a ${line} ${MTK_ANDROID_PATH}"
        cp -a ${line} ${MTK_ANDROID_PATH}
    done < <(ls)
    popd >/dev/null
}

function copyPackageDir()
{
    if [ "${MTK_PACKAGES_DIR_FLAG}" != "TRUE" ];then
        return
    fi
    echo "function copyPackageDir"
    echo "cp -a ${MTK_PATCH_PATH}/packages/ ${MTK_PACKAGES_NAME}"
    cp -a ${MTK_PATCH_PATH}/packages/* ${MTK_PACKAGES_NAME}
}

# Added by liubingzhao. begin
function checkDiffDir() {
    if [ -d ${DIFF_PATH} ]; then
        rm -r ${DIFF_PATH}
    fi
    mkdir ${DIFF_PATH}
}

function generateAndroidDiffs() {
    pushd ${MTK_ANDROID_PATH} > /dev/null
    #git add -A .
    #git diff --name-only --cached > ${ANDROID_DIFF_LIST}
    git status -s > ${ANDROID_DIFF_LIST}
    while read line; do
        line=${line:3}
        if [ ! -f ${line} ]; then
            continue
        fi
        echo 为${line}生成diff
        local targetfile=${ANDROID_DIFF_PATH}/${line}
        local targetdir=$(dirname ${targetfile})
        local filename=$(basename ${targetfile})
        if [ ! -d ${targetdir} ]; then
            mkdir -p ${targetdir}
        fi
        git diff --cached ${line} > ${targetdir}/${filename}.diff
    done < ${ANDROID_DIFF_LIST}
    popd > /dev/null
}

function generatePackagesDiffs() {
    pushd ${MTK_PACKAGES_NAME} > /dev/null
    #git add -A .
    #git diff --name-only --cached > ${PACKAGES_DIFF_LIST}
    git status -s > ${PACKAGES_DIFF_LIST}
    while read line; do
        line=${line:3}
        if [ ! -f ${line} ]; then
            continue
        fi
        echo 为${line}生成diff
        local targetfile=${PACKAGES_DIFF_PATH}/${line}
        local targetdir=$(dirname ${targetfile})
        local filename=$(basename ${targetfile})
        if [ ! -d ${targetdir} ]; then
            mkdir -p ${targetdir}
        fi
        git diff --cached ${line} > ${targetdir}/${filename}.diff
    done < ${PACKAGES_DIFF_LIST}
    popd > /dev/null
}

function generateDiffs() {
    checkDiffDir
    generateAndroidDiffs
    generatePackagesDiffs
}

function checkCompareApp() {
    COMPARE_APPS="bcompare meld"
    COMPARE_APP=
    local item
    for item in ${COMPARE_APPS}; do
        which ${item} >/dev/null
        if [ $? -eq 0 ];then
            COMPARE_APP=${item}
            echo "比较软件：${COMPARE_APP}"
            return
        fi
    done
    echo -e "${COLOR_ERROR_PREFIX}没有找到可用比较软件(如meld、bcompare等)，请安装后再操作！${COLOR_SUFFIX}"
    exit
}

function checkPwd() {
    local curDir=$(basename $(pwd))
    if [[ ${curDir} != *android* ]]; then
        echo -e "${COLOR_ERROR_PREFIX} 当前不是 android 主目录，请进入 android 主目录执行此脚本！${COLOR_SUFFIX}"
        exit
    elif [[ ! -d .git ]]; then
        echo -e "${COLOR_ERROR_PREFIX} 当前不是 git 库目录，请进入 android 主目录执行此脚本！${COLOR_SUFFIX}"
        exit
    fi
}

function rmScript() {
    local scriptName=$(basename $0)
    if [ -f ${scriptName} ]; then
        echo -e "${COLOR_WARNING_PREFIX} 好像执行脚本 ${scriptName} 被放在的当前目录下了，删除吗 (Y/N)? ${COLOR_SUFFIX}"
        read answer < /dev/tty
        if [[ ${answer} == y || ${answer} == Y ]]; then
            rm ${scriptName}
            if [ $? -eq 0 ]; then
                echo -e "${COLOR_GREEN_PREFIX} 已成功删除${scriptName} ${COLOR_SUFFIX}"
            fi
        fi
    fi
}
# Added by liubingzhao. end

function modifyPatchListAPPXls()
{
    echo "function modifyPatchListAPPXls"
    pushd ${MTK_PATCH_PATH} >/dev/null
    while read line
    do
        echo -e "${COLOR_WARNING_PREFIX} 请手动修改 PatchList_APP.xls！ ${COLOR_SUFFIX}"
        gedit ${line} &
        libreoffice ${MTK_ANDROID_PATH}/PatchList_APP.xls
    done < <(find . -maxdepth 1 -type f)
    popd >/dev/null
}

function changeVersionNumber()
{
    #echo "function changeVersionNumber [$@]"
    local tmpVersionNew="$1"
    local tmpVersionPrefix="$2"
    local tmpVersionFile="$3"
    if [ -z "$tmpVersionNew" ];then
        echo -e "${COLOR_ERROR_PREFIX} The new versions can not be empty${COLOR_SUFFIX}"
        exit 1
    fi
    if [ ! -f "$tmpVersionFile" ];then
        echo -e "${COLOR_ERROR_PREFIX} $tmpVersionFile file does not exist${COLOR_SUFFIX}"
        exit 2
    fi
    local tmpVersionOld=$(cat $tmpVersionFile | sed -n "/$tmpVersionPrefix/p")
    #echo "tmpVersionOld:[${tmpVersionOld}]"
    if [ -z "$tmpVersionOld" ];then
        echo -e "${COLOR_ERROR_PREFIX} No \"$tmpVersionPrefix\" in the $tmpVersionFile ${COLOR_SUFFIX}"
        exit 3
    fi
    tmp=$(echo ${tmpVersionOld%=*})
    newversion="${tmp} = ${tmpVersionNew}"
    echo "sed -i \"s@$tmpVersionOld@$newversion@\" $tmpVersionFile"
    sed -i "s@$tmpVersionOld@$newversion@" $tmpVersionFile
    if [ $? -ne 0 ];then
        echo -e "${COLOR_ERROR_PREFIX} Modify version for sed commond fail! ${COLOR_SUFFIX}"
        exit 4
    fi
}

function modifyVerForProjectMK()
{
    echo "function modifyVerForProjectMK"
    if [ ! -e ${MTK_ANDROID_PATH}/gionee/config ];then
        echo -e "${COLOR_ERROR_PREFIX} Dir ${MTK_ANDROID_PATH}/gionee does not exsit!${COLOR_SUFFIX}"
        exit 1
    fi
    pushd ${MTK_ANDROID_PATH}/gionee/config >/dev/null
    while read line
    do
        local tmpWeekNo=$(grep "MTK_WEEK_NO" ${line} | awk -F '=' '{printf("%s",$2)}' | sed s/[[:space:]]//g)
        local tmpBuildNo=$(grep "MTK_BUILD_VERNO" ${line} | awk -F '=' '{printf("%s",$2)}' | sed s/[[:space:]]//g)
        if [[ -z ${tmpWeekNo} || -z ${tmpBuildNo} ]];then
            continue
        fi
        local tmpMtkProject=$(grep "TARGET=" ${line} | awk -F '=' '{printf("%s",$2)}' | sed s/[[:space:]]//g)
        if [ -z "${tmpMtkProject}" ];then
            continue
        fi
        getBuildVernoFromPatch "${tmpMtkProject}"
        changeVersionNumber "${PATCH_WEEK_NO}" "MTK_WEEK_NO" "${line}"
        changeVersionNumber "${PATCH_BUILD_VERNO}" "MTK_BUILD_VERNO" "${line}"
    done < <(find ./ -maxdepth 1 -type f -name '*.mk')
    popd >/dev/null
}

function manualPortingGioneeFiles()
{
    local i=${1}
    local tmpPath=${2}
    local opt_type=
    if [[ ${i} == D\ * ]]; then
        opt_type=DELETE
        i=${i#*D }
    elif [[ ${i} == ??\ * ]]; then
        opt_type=ADD
        i=${i#*?? }
    elif [[ ${i} == M\ * ]]; then
        opt_type=MODIFY
        i=${i#*M }
    else
        echo -e "${COLOR_ERROR_PREFIX} 未知的操作类型，操作只能是[M|A|D]，还继续吗？(Y/N)${COLOR_SUFFIX}"
        read answer < /dev/tty
        if [[ ${answer} == Y || ${answer} == y ]]; then
            return
        else
            exit 1
        fi
    fi
    local fileName=$(basename ${i})
    if [[ ${opt_type} == DELETE ]]; then
        echo -e "${COLOR_WARNING_PREFIX} 有删除文件：[${i}] ${COLOR_SUFFIX}"
    fi
    while read j
    do
        if [[ ${opt_type} == DELETE ]]; then
            echo "${j}" >> ${DELETE_GN_LIST}
            pushd ./gionee > /dev/null
            git log -n1 "${j#*gionee/}" >> ${DELETE_GN_LIST}
            echo >> ${DELETE_GN_LIST}
            popd > /dev/null
            echo -e "${COLOR_WARNING_PREFIX} 要删除 [${j}] 吗？ (Y/N/直接回车跳过)${COLOR_SUFFIX}"
            read answer < /dev/tty
            if [[ ${answer} == Y || ${answer} == y ]]; then
                echo rm ${j}
                rm ${j}
                echo "${j}" >> ${DELETED_GN_LIST}
            fi
            continue
        fi
        if [ -z "$(file -b ${j} | grep ' text')" ]; then
            echo -e "${COLOR_WARNING_PREFIX} 略过二进制文件: [${j}]${COLOR_SUFFIX}"
            pushd ./gionee > /dev/null
            if [[ ${j} == *.so ]]; then
                echo ${j} >> ${SO_LIST}
                git log -n1 "${j#*gionee/}" >> ${SO_LIST}
                echo >> ${SO_LIST}
                continue
            elif [[ ${j} == *.jar ]]; then
                echo ${j} >> ${JAR_LIST}
                git log -n1 "${j#*gionee/}" >> ${JAR_LIST}
                echo >> ${JAR_LIST}
                continue
            else
                echo ${j} >> ${BINARY_LIST}
                git log -n1 "${j#*gionee/}" >> ${BINARY_LIST}
                echo >> ${BINARY_LIST}
                continue
            fi
            popd > /dev/null
        fi
        # 如果需要跳过一些目录或文件，在这里判断
        if [[ ${j} == */chromatix/* ]]; then
            echo ${j} >> ${IGNORE_LIST}
            continue
        fi
        local THE_DIR=${MTK_ANDROID_PATH}
        echo -e "${COLOR_WARNING_PREFIX}patch  :[${i}]${COLOR_SUFFIX}"
        echo -e "${COLOR_WARNING_PREFIX}gionee :[${j}]${COLOR_SUFFIX}"
        if [ -z "${2}" ]; then
            THE_DIR=${MTK_ANDROID_PATH}
            echo -e "${COLOR_WARNING_PREFIX}diff   :[${ANDROID_DIFF_PATH}/${i}.diff]${COLOR_SUFFIX}"
            patch ${j} ${ANDROID_DIFF_PATH}/${i}.diff
        elif [[ ${2} == packages ]]; then
            THE_DIR=${MTK_PACKAGES_NAME}
            echo -e "${COLOR_WARNING_PREFIX}diff   :[${PACKAGES_DIFF_PATH}/${i}.diff]${COLOR_SUFFIX}"
            patch ${j} ${PACKAGES_DIFF_PATH}/${i}.diff
        fi
        local ret=$?
        if [ ${ret} -ne 0 ];then
            echo -e "${COLOR_ERROR_PREFIX} 未能成功合入， patch命令执行结果 :${ret} ${COLOR_SUFFIX}"
            echo ${j} >> ${FAIL_LIST}
            if [ ${ret} -eq 2 ]; then
                echo ${j} >> ${SAME_LIST}
            fi
        else
            echo -e "${COLOR_GREEN_PREFIX} 已成功合入: [${j}]${COLOR_SUFFIX}"
            echo
            echo ${j} >> ${SUCCESS_LIST}
        fi
        if [ -f ${j}.rej ]; then
            echo -e "${COLOR_GREEN_PREFIX} 请确认是否手动 merge 以上文件（Y/N）:${COLOR_SUFFIX}"
            read answer < /dev/tty
            if [[ ${answer} = "y" || ${answer} = "Y" ]]; then
                gedit ${j}.rej &
                echo "${COMPARE_APP} ${THE_DIR}/${i} ${j}"
                ${COMPARE_APP} ${THE_DIR}/${i} ${j}
            fi
            rm ${j}.rej
        fi
        if [ -f ${j}.orig ]; then
            rm ${j}.orig
        fi
    done < <(find gionee/ \( -path "*.git" -o -path "*YouJuAgent*" -o -path "*amigoframework*" -o -path "*gnframework-res*" \) -prune -o -name ${fileName} -print | grep "$i")
}

function manualPortingInAndroidGioneePath()
{
    echo "function manualPortingInAndroidGioneePath"
    if [ ! -s ${ANDROID_DIFF_LIST} ]; then
        echo  -e "${COLOR_WARNING_PREFIX} android 目录无改动${COLOR_SUFFIX}"
    fi
    while read i
    do
        pushd ${MTK_ANDROID_PATH} >/dev/null
        manualPortingGioneeFiles "${i}" # "alps"
        popd >/dev/null
    done < ${ANDROID_DIFF_LIST}
}

function manualPortingInPackageGioneePath()
{
    echo "function manualPortingInPackageGioneePath"
    if [ ! -s ${PACKAGES_DIFF_LIST} ]; then
        echo  -e "${COLOR_WARNING_PREFIX} packages 目录无改动${COLOR_SUFFIX}"
    fi
    while read i
    do
        pushd ${MTK_PACKAGES_NAME} >/dev/null
        manualPortingGioneeFiles "${i}" "packages"
        popd >/dev/null
    done < ${PACKAGES_DIFF_LIST}
}

function checkStatus()
{
    echo "function checkStatus"
    echo "结束！请使用 'repo status'、'git status' 等命令查看改动"
    #repo status
}

function main()
{
    #判断当前目录是否正确，在android主目录执行脚本
    checkPwd
    #判断比较软件是否安装
    checkCompareApp

    initLocalVar "$@"
    #如果当前是 repo 管理项目，则计算出各个 git 子库路径
    #countRepoProjectList
    #检查当前 patch 中是否有 delete 的文件
    #checkDeleteFileFromPatch
    #拷贝 android 下的代码（由于 android 目录没有 Gionee 的修改，因此直接覆盖即可）
    #copyAndroidDir
    #拷贝 packages 下的代码（由于 packages 目录没有 Gionee 的修改，因此直接覆盖即可）
    #copyPackageDir

    #为每个文件生成diff
    generateDiffs

    #修改 gionee/config/项目.mk 文件，这个主要修改 patch 号
    #modifyVerForProjectMK
    #修改 PatchList_APP.xls ，记录当前集成的 patch 列表
    #modifyPatchListAPPXls
    #判断如果 android/gionee 目录下存在修改的文件，则手动进行 merge
    manualPortingInAndroidGioneePath
    #判断如果 packages/gionee 目录下存在修改的文件，则手动进行 merge
    manualPortingInPackageGioneePath
    #如果此脚本在当前目录下，则删除
    rmScript
    #列出所有变动
    checkStatus
    #rm $0
}

main "$@"
