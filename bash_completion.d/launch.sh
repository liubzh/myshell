#!/bin/bash

######## Script Information. BGN ########
# Author: liubingzhao.
# Date: 2016-12-27
# Relative Command: commands/adb
######## Script Information. END ########

function _launch_sh() {
    local my_opts="GNLog DocumentsUI FileManager LogFairy MMI"
    local cur prev opts

    COMPREPLY=()

    cur="${COMP_WORDS[COMP_CWORD]}"
    opts="${my_opts}"

    if [ -n "${opts}" ]; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    fi
    return 0
}

complete -o default -F _launch_sh launch.sh
