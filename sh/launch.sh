#!/bin/bash

######## Script Information. BGN ########
# Author: liubingzhao.
# Date: 2016-12-28
# Introduction: Pick one or more from the pool.
######## Script Information. END ########

# All the global variables in this script.
function init_global_variables() {
    :
}

function print_help() {
    cat << Help
launch.sh | Launch an application using adb shell command.
Usage: launch.sh <APP>
Help
}

# Parse and validate the arguments.
# Return 0: ok
# Return 1: invalid or print help.
function parse_and_check_args () {
    if [ -z "$1" ]; then
        print_help
        return 1
    fi
    while [ $# -gt 0 ];do
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

function main() {
    init_global_variables
    parse_and_check_args "$@"
    case "$?" in
    1)
        return 0
        ;;
    esac
    local component
    case "$1" in
    GNLog)
        component=com.gionee.logger/com.gionee.logger.GNLogger
        ;;
    DocumentsUI)
        component=com.android.documentsui/com.android.documentsui.DocumentsActivity
        ;;
    FileManager)
        component=com.gionee.filemanager/.FileExplorerTabActivity
        ;;
    MMI)
        component=gn.com.android.mmitest/.GnMMITest
        ;;
    esac
    if [ ${component} ]; then
        adb shell am start -n ${component}
    else
        echo "Unknown application: ${1}"
    fi
}

main "$@"
