#!/bin/bash

# 配置mysh，所有mysh下的命令生效。

FILE=$HOME/.bashrc

STR="source $HOME/mysh/source"
ADD="
#Added by Binzo. begin
$STR
#Added by Binzo. end
"

#在目标文件中查找字符串是否存在
if [ ! -f $FILE ]; then
    echo "目标文件不存在!"
    return 0
fi
search=`grep "$STR" $FILE`
if [ -n "$search" ]; then
    found=true
    echo "无须再次写入!"
fi

#若不存在，添加至文件尾部
if [ ! $found ]; then
    echo "$ADD" >> $FILE
    echo "写入成功!"
    #立即生效
    $STR
fi

# 如果是64位操作系统，在安装新程序的时候会用到32位库依赖
# Android Studio的安装，有如下库依赖。
# sudo apt install lib32z1 lib32ncurses5  lib32stdc++6
# sudo apt -f install
