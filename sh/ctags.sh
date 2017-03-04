#!/bin/bash

######## Script Information. BGN ########
# Author: liubingzhao.
# Date: 2017-01-23
######## Script Information. END ########

# All the global variables in this script.
function init_global_variables() {
    dir_java=libcore/luni/src/main/java:java
    dir_javax=libcore/luni/src/main/java:javax
    dir_android=frameworks/base/core/java:android
    dir_android_internal=frameworks/base/core/java:com/android/internal
    target_dirs="${dir_java} ${dir_javax} ${dir_android} ${dir_android_internal}"
    target_dirs="${dir_java}"
    dir_out=/tmp/tags
}

function print_help() {
    cat << Help
ctags.sh | Binzo's customized command 'ctags'.
Help
}

function parse_and_check_args () {
    while [ $# -gt 0 ]; do
        case "$1" in
        -h|--help|\?)
            print_help
            return 1    # exit.
            ;;
        *)
            shift
            ;;
        esac
    done
}

function gen_packages() {
    if [ -z "${MY_GN_PROJDIR}" ]; then
        echo "MY_GN_PROJDIR is null"
        return 1
    fi
    local dir_root=${MY_GN_PROJDIR}/L*/android*
    if [ -d ${dir_out} ]; then
        rm -r ${dir_out}/*
    else
        mkdir -p ${dir_out}
    fi
    local dir1 dir2
    local file=${dir_out}/java_packages
    local out=~/.vim/tags/java_packages.tags
    touch ${file}
    for dir in ${target_dirs}; do
        dir1=${dir%:*}
        dir2=${dir#*:}
        echo $dir1 $dir2
        cd ${dir_root}
        if [ ! -d ${dir1} ]; then
            echo ${dir1} does not exist.
            return 1
        fi
        cd ${dir1}
        find ${dir2} -type d >> ${file}
    done
    vim ${file}
    local line
    while read line; do
        line=${line////.}
        echo "${line}	java	/^import ${line};$/;\"  p" >> ${out}
    done < ${file}
}

function gen_import() {
    if [ -z "${MY_GN_PROJDIR}" ]; then
        echo "MY_GN_PROJDIR is null"
        return 1
    fi
    target_dirs="${dir_java}"
    local dir_out=/tmp/tags
    local dir_root=${MY_GN_PROJDIR}/L*/android*
    if [ -d ${dir_out} ]; then
        rm -r ${dir_out}/*
    else
        mkdir -p ${dir_out}
    fi
    local dir1 dir2
    for dir in ${target_dirs}; do
        dir1=${dir%:*}
        dir2=${dir#*:}
        echo $dir1 $dir2
        cd ${dir_root}
        if [ ! -d ${dir1} ]; then
            echo ${dir1} does not exist.
            return 1
        fi
        cd ${dir1}
        find ${dir2} -name *.java >> ${dir_out}/java_import
    done
    #vim ${dir_out}/java_import
    #ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .
}

function gen_import_tags() {
    if [ -z "$1" ]; then
        echo "No argument."
        return 1
    elif [ ! -f "$1" ]; then
        echo "No such file: $1"
        return 1
    fi
    local line
    while read line; do
        #line=${line%.java*}
        #while [[ ${line} == */* ]]; do
        #    cls=${line%%/*}
        #    line=${line#*/}
        #    var=${line%%/*}
        #    #echo cls=${cls} var=${var}
        #    local file=${dir_out}/${cls}.java
        #    if [ ! -f ${file} ]; then
        #        echo "public class ${cls} {" > ${file}
        #    fi
        #    if [ -z "`grep "int ${var}" ${file}`" ]; then
        #        echo "  int ${var};" >> ${file}
        #    fi
        #done
        line=${line%.java*}
        local cls_name=${line##*/}
        local pkg_name=${line%/*}
        pkg_name=${pkg_name////.}
        echo pkg=${pkg_name} cls=${cls_name}
        local file_pkg=${dir_out}/pkg.tags
        echo "${pkg_name}	${cls_name}.java	/^package ${pkg_name};$/;\"  p" >> ${file_pkg}
    done < ${1}
    #cd ${dir_out}
    #for item in *.java; do
    #    echo "}" >> ${item}
    #done
    #ctags -R --java-kinds=+p --fields=+iaS --extra=+q .
    #vim tags
}

function gen_tags_in_a_file() {
    if [ -z "$1" ]; then
        echo "No argument."
        return 1
    elif [ ! -f "$1" ]; then
        echo "No such file: $1"
        return 1
    fi
    if [ -z "${MY_GN_PROJDIR}" ]; then
        echo "MY_GN_PROJDIR is null"
        return 1
    fi
    if [ -d ${dir_out} ]; then
        for item in ${dir_out}/*; do
            rm -r ${dir_out}/*
            break
        done
    else
        mkdir -p ${dir_out}
    fi
    local file=${dir_out}/import
    local files
    grep "^import " $1 > ${file}
    while read line; do
        line=${line#*import }
        line=${line%;*}
        line=${line//.//}.java
        if [[ ${line} == com/android/internal* ]]; then
            files="${files} frameworks/base/core/java/${line}" 
        elif [[ ${line} == java/* ]]; then
            files="${files} libcore/luni/src/main/java/${line}" 
        elif [[ ${line} == javax/* ]]; then
            files="${files} libcore/luni/src/main/java/${line}" 
        elif [[ ${line} == android/graphics/* ]]; then
            files="${files} frameworks/base/graphics/java/${line}" 
        elif [[ ${line} == android/media/* ]]; then
            files="${files} frameworks/base/media/java/${line}" 
        elif [[ ${line} == android/* ]]; then
            files="${files} frameworks/base/core/java/${line}" 
        fi
    done < ${file}
    local dir_root=${MY_GN_PROJDIR}/L*/android*
    cd ${dir_root}
    ctags -R --java-kinds=+p --fields=+iaS --extra=+q ${files}
    if [ -f tags ]; then
        mv ./tags ~/.vim/tags/current.tags
    fi
}

function main() {
    init_global_variables

    # Check arguments.
    parse_and_check_args "$@"
    if (( 0 != $? )); then return 1; fi

    #gen_import
    #if (( 0 != $? )); then return 1; fi

    #gen_import_tags /tmp/tags/java_import
    #if (( 0 != $? )); then return 1; fi

    #gen_packages
    #if (( 0 != $? )); then return 1; fi

    gen_tags_in_a_file "$1"
    if (( 0 != $? )); then return 1; fi
}

main "$@"
