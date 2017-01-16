#!/bin/bash

######## Script Information. BGN ########
# Author: liubingzhao.
# Date: 2016-12-28
# Introduction: Pick one or more from the pool.
######## Script Information. END ########

# All the global variables in this script.
function init_global_variables() {
    # The pool
    POOL=
    POOL_ARRAY=
    # The count it should pick.
    COUNT=
    # The items which have been picked.
    WINNER=
}

function print_help() {
    cat << Help
lottery.sh | Binzo's command to choose one or more items from many ones in the pool.
Usage: lottery.sh <ITEMS> | <FILE>
  <ITEMS>              Specify all the items you want to choose in.
  <FILE>               Specify one file as the items you want to choose in.
Eg. lottery.sh item1 item2 item3
    lottery.sh ~/items.txt
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
    if [ -f "$1" ]; then
        POOL=$(cat "$1")
        return 0 # Normal return.
    fi
    while [ $# -gt 0 ];do
        case "$1" in
        -h|--help|\?)
            print_help
            return 1    # exit.
            ;;
        *)
            POOL="${POOL} $1"
            shift
            ;;
        esac
    done
}

function pick() {
    local result=
    local random=$((${RANDOM}%${#POOL_ARRAY[@]}))
    #echo "Random number is ${random}"
    result=${POOL_ARRAY[${random}]}
    WINNER+="${result} "
    POOL_ARRAY[${random}]=
    POOL=${POOL_ARRAY[*]}
    POOL_ARRAY=(${POOL})
}

# Return 0: is a number.
# Return 1: is not a number.
function chkInt() {
    case "$1" in
        [0-9]*) 
            return 0
            ;;
        *) 
            echo "$1 is not a valid positive number."
            return 1
            ;;
    esac 
}

function main() {
    parse_and_check_args "$@"
    case "$?" in
    1)
        return 0
        ;;
    esac
    POOL_ARRAY=(${POOL})
    while [ true ]; do
        if [ -n "${POOL}" ]; then
            WINNER=
            echo "-----------POOL-----------"
            echo ${POOL}
            echo "--------------------------"
            read -p "Input the number you want to pick, press <Enter> to pick only one: " COUNT
            if [ -z "${COUNT}" ]; then
                COUNT=1
            fi
            chkInt ${COUNT}
            if [ $? -eq 1 ]; then
                # COUNT is not a number.
                read -p "Press <Enter> to continue..."
                continue
            else
                # COUNT is a number.
                let num=`expr ${COUNT}`
                if [ ${num} -gt ${#POOL_ARRAY[@]} -o ${num} -le 0 ]; then
                    echo "The number should be in the range (0,${#POOL_ARRAY[@]})"
                    read -p "Press <Enter> to continue..."
                    continue
                fi
                while [ ${num} -gt 0 ]; do
                    pick
                    let num=`expr ${num} - 1`
                done
            fi
            echo "----------WINNER----------"
            echo ${WINNER}
            echo "--------------------------"
            read -p "Press <Enter> to continue, 'Ctrl-c' to exit..."
        else
            echo "The pool is empty, can not pick!"
            break
        fi
    done
}

main "$@"
