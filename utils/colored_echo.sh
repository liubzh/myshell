#!/bin/bash

MY_WHITE="\\033[0m"
MY_RED="\\033[31m"
MY_YELLOW="\\033[33m"
MY_GREEN="\\033[32m"

# 打印红色文本
echoE() {
    echo -e "${MY_RED}$*${MY_WHITE}"
}

# Info 打印绿色文本
echoI() {
    echo -e "${MY_GREEN}$*${MY_WHITE}"
}

# Warning 打印黄色文本
echoW() {
    echo -e "${MY_YELLOW}$*${MY_WHITE}"
}
