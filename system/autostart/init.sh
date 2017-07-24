#!/bin/bash

# 设置进程自启动，比如开机启动Synergy。

DIR_FROM=.
DIR_TO=$HOME/.config/autostart

if [ ! -d $DIR_TO ]; then
    echo "目标文件不存在,创建目录$DIR_TO!"
    mkdir -p $DIR_TO
fi

cp $DIR_FROM/* $DIR_TO
