#!/bin/bash

function install() {
    # brew list 命令可以查看安装的组件
    # brew info bash-completion 命令可以查看目标组件信息
    brew install bash-completion
    echo '[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion' >> ~/.bash_profile
}

install
