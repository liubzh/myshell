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
    PUTBACK=false
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
        shift
    fi
    while [ $# -gt 0 ];do
        case "$1" in
        -h|--help|\?)
            print_help
            return 1    # exit.
            ;;
        --putback)
            PUTBACK=true
            shift
            ;;
        --noputback)
            PUTBACK=false
            shift
            ;;
        --dice)
            PUTBACK=true
            POOL="1 2 3 4 5 6"
            shift
            ;;
        --coin)
            PUTBACK=true
            POOL="Heads Tails"
            shift
            ;;
        *)
            if [ -z "${POOL}" ]; then
                POOL="$1"
            else
                POOL="${POOL} $1"
            fi
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
    WINNER+=" ${result}"
    if ! ${PUTBACK}; then
        POOL_ARRAY[${random}]=
        POOL=${POOL_ARRAY[*]}
        POOL_ARRAY=(${POOL})
    fi
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
    init_global_variables
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
            echo "POOL{" ${POOL} "}"
            if ! ${PUTBACK}; then
                read -p "How many do you want to pick (default is 1): " COUNT
            fi
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
                    echo "The number should be in the range [1,${#POOL_ARRAY[@]}]"
                    read -p "Press <Enter> to continue..."
                    continue
                fi
                while [ ${num} -gt 0 ]; do
                    pick
                    let num=`expr ${num} - 1`
                done
            fi
            echo "WINNER|" ${WINNER}
            read -p "Continue (y/n)? " ANSWER
            if [[ -z ${ANSWER} || ${ANSWER} == y || ${ANSWER} == Y ]]; then
                continue
            else
                return 1
            fi
        else
            echo "The pool is empty, can not pick!"
            break
        fi
    done
}

main "$@"
