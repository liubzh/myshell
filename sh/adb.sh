#!/bin/bash

######## Script Information. BGN ########
# Author: liubingzhao.
# Date: 2016-12-23
# Relative Completion: bash_completion.d/adb
######## Script Information. END ########

function print_help() {
case "$1" in
logcat)
    cat << Help
Usage: logcat [options] [filterspecs]
options include:
  -s              Set default filter to silent.
                  Like specifying filterspec '*:S'
  -f <filename>   Log to file. Default is stdout
  -r <kbytes>     Rotate log every kbytes. Requires -f
  -n <count>      Sets max number of rotated logs to <count>, default 4
  -v <format>     Sets the log print format, where <format> is:

                      brief color long printable process raw tag thread
                      threadtime time usec

  -D              print dividers between each log buffer
  -c              clear (flush) the entire log and exit
  -d              dump the log and then exit (don't block)
  -t <count>      print only the most recent <count> lines (implies -d)
  -t '<time>'     print most recent lines since specified time (implies -d)
  -T <count>      print only the most recent <count> lines (does not imply -d)
  -T '<time>'     print most recent lines since specified time (not imply -d)
                  count is pure numerical, time is 'MM-DD hh:mm:ss.mmm'
  -g              get the size of the log's ring buffer and exit
  -L              dump logs from prior to last reboot
  -b <buffer>     Request alternate ring buffer, 'main', 'system', 'radio',
                  'events', 'crash' or 'all'. Multiple -b parameters are
                  allowed and results are interleaved. The default is
                  -b main -b system -b crash.
  -B              output the log in binary.
  -S              output statistics.
  -G <size>       set size of log ring buffer, may suffix with K or M.
  -p              print prune white and ~black list. Service is specified as
                  UID, UID/PID or /PID. Weighed for quicker pruning if prefix
                  with ~, otherwise weighed for longevity if unadorned. All
                  other pruning activity is oldest first. Special case ~!
                  represents an automatic quicker pruning for the noisiest
                  UID as determined by the current statistics.
  -P '<list> ...' set prune white and ~black list, using same format as
                  printed above. Must be quoted.

filterspecs are a series of 
  <tag>[:priority]

where <tag> is a log component tag (or * for all) and priority is:
  V    Verbose (default for <tag>)
  D    Debug (default for '*')
  I    Info
  W    Warn
  E    Error
  F    Fatal
  S    Silent (suppress all output)

'*' by itself means '*:D' and <tag> by itself means <tag>:V.
If no '*' filterspec or -s on command line, all filter defaults to '*:V'.
eg: '*:S <tag>' prints only <tag>, '<tag>:S' suppresses all <tag> log messages.

If not specified on the command line, filterspec is set from ANDROID_LOG_TAGS.

If not specified with -v on command line, format is set from ANDROID_PRINTF_LOG
or defaults to "threadtime"
Help
    ;;
*)
    ;;
esac
}

# Parse and validate the arguments.
# return 0: ok
# return 1: invalid or print help.
function parse_and_check_args ()
{
    local command_name=
    if [[ $1 == -h && $1 == --help && $1 == ? ]]; then
        return 0 # let adb itself to process these arguments.
    else
        command_name="$1"; shift
    fi
    while [ $# -gt 0 ];do
        case "$1" in
        -h|--help|\?)
            print_help ${command_name}
            exit 0    # 直接退出
            ;;
        *)
            shift
            ;;
        esac
    done
}

# 连接多个设备情况需选择
function choose_adb_device() {
    local delimiter="__:__"  # 约定分隔符
    local devices=
    while read line; do
        if [[ ${line} == *\ device\ * ]]; then
            line=${line// /_}
            local device_id=${line%%_*}
            local device=${line#*device:}
            devices="${devices} ${device}${delimiter}${device_id}"
        fi
    done < <(${ADB} devices -l)
    local count=$(echo ${devices} | grep -o "${delimiter}" | wc -l)
    local selection=
    if [ ${count} -eq 1 ]; then
        # 如果只有一个可访问设备，则无需选择
        selection=${devices}
    elif [ ${count} -lt 1 ]; then
        return
    else
        echo "多个设备请选择"
    fi
    while [ -z "${selection}" ]; do
        select selection in ${devices}; do
            :
            break
        done
    done
    selection=${selection##*${delimiter}}  # 约定分隔符_:_
    TARGET_DEVICE=" -s ${selection} "
}

function main() {
    if [ -z "${ANDROID_SDK_HOME}" ]; then
        echo "需要定义环境变量: ANDROID_SDK_HOME"
        exit 2
    fi
    ADB=$ANDROID_SDK_HOME/platform-tools/adb
    if [ ! -f ${ADB} ]; then
        echo "adb 命令不存在：${ADB}"
        exit 1
    fi
    parse_and_check_args "$@"

    TARGET_DEVICE=
    choose_adb_device
    ${ADB} ${TARGET_DEVICE} "$@"
}

main "$@"
