#!/bin/bash

TAG=vim/init.sh

function chkInstall(){
    pkg=$1
    if [ -z "$1" ]; then
        echoE "$TAG - chkInstall() 参数缺失"
        return 0
    fi
    pkgInstalled $pkg
    if [ $? == 0 ]; then
        read -p "安装吗?：(Enter/Y/y)" ANSWER
        if [ "$ANSWER" == "Y" -o "$ANSWER" = "y" -o -z "$ANSWER" ]; then
            sudo apt-get install $pkg
        fi
    fi
}

# 安装vim
chkInstall vim

# 安装vim-gnome
chkInstall vim-gnome
 
# 变量之间的跳转
chkInstall ctags

# 其中有vim-addon-manager,vim-addons等
#chkInstall vim-scripts

#vim-addons install taglist


# Customizing my own vim. BEGIN
if [ -z "$MYSHELLDIR" ]; then
    echo "\$MYSHELLDIR未定义,请执行mysh/init.sh进行初始化."
    exit 0
fi
MY_VIM_DIR=$MYSHELLDIR/vim
if [ ! -d ~/.vim ]; then
    ln -ds $MY_VIM_DIR ~/.vim  # Link .vim directory.
    echoI link .vim
fi
if [ ! -f ~/.vimrc ]; then
    ln -s $MY_VIM_DIR/vimrc ~/.vimrc # Link .vimrc file.
    echoI link .vimrc
fi
# Customizing my own vim. END
