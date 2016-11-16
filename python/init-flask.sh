#!/bin/bash

# virtualenvwrapper命令总结

# 创建虚拟环境
# mkvirtualenv env

# 切换虚拟环境
# workon env

# 取消激活状态
# deactivate

# 删除虚拟环境
# rmvirtualenv env


TAG=python/init-flask

MY_VENV="env35"

# 先执行下取消激活虚拟环境，避免当前处于虚拟环境中
deactivate

if [[ $(workon) == $MY_VENV ]]; then
    echo "虚拟环境$MY_VENV已存在"
    workon $MY_VENV
else
    MY_CMD="mkvirtualenv $MY_VENV --python=/usr/bin/python3.5"
    echoW "没有虚拟环境env,执行：$MY_CMD"
    $MY_CMD
fi

function pipInstall() {
    if [ -z "$1" ]; then
        echoE "缺少参数"
    fi
    MY_CMD="pip install $1"
    echoW $MY_CMD
    $MY_CMD
}

# 安装pillow之前，需要安装依赖库：
sudo apt install libjpeg-dev
sudo apt install libfreetype6-dev
sudo apt install python3.5-dev

ITEMS="flask flask-script flask-bootstrap flask-moment flask-wtf flask-sqlalchemy flask-migrate flask-mail flask-login flask-pagedown markdown bleach pillow forgerypy flask-httpauth httpie"

for item in $ITEMS; do
    pipInstall $item
    chk_return
done

deactivate
