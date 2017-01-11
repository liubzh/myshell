#!/bin/bash

######## Script Information. BGN ########
# Author: liubingzhao.
# Date: 2017-01-11
# Discription: Localization and internationalization
######## Script Information. END ########

function main() {
    local input_dir="${MYSHELLDIR}/lang/zh_CN"
    local output_dir="${MYSHELLDIR}/lang/locale/zh/LC_MESSAGES"
    local input_file=
    local output_file=
    local item=
    for item in $(ls ${input_dir}); do
        input_file="${input_dir}/${item}"
        item="${item%.*}.mo"
        output_file="${output_dir}/${item}"
        #echo ${input_file} ${output_file}

        # Core command here.
        msgfmt -o ${output_file} ${input_file}
        printf "${item} "
    done
    echo # New line
}

main "$@"
