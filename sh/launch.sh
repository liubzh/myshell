#!/bin/bash

######## Script Information. BGN ########
# Author: liubingzhao.
# Date: 2016-12-28
# Introduction: 使用 ADB 命令运行 APP
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
    case $(echo $1 | tr '[:lower:]' '[:upper:]') in
    GNLOG)
        component=com.gionee.logger/com.gionee.logger.GNLogger
        ;;
    LOGFAIRY)
        component=onekeylog.gionee.com.onekeylog/com.gionee.onekeylog.test.MainActivity
        ;;
    DOCUMENTSUI)
        component=com.android.documentsui/com.android.documentsui.DocumentsActivity
        ;;
    FILEMANAGER)
        component=com.gionee.filemanager/.FileExplorerTabActivity
        ;;
    MMI)
        component=gn.com.android.mmitest/.GnMMITest
        ;;
    PUPPYAI)
        component=com.puppy.ai/.MainActivity
        ;;
    PUPPYAI_SETTINGS)
        component=com.puppy.ai/.settings.PuppyAiSettings
        ;;
    esac
    if [ ${component} ]; then
        adb shell am start -n ${component}
    else
        echo "Unknown application: ${1}"
    fi
}

main "$@"
