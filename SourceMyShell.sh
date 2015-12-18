#!/bin/bash

# My shell scripts evironment variable. It's important.
# 我的Shell脚本路径环境变量，很重要。
MYSHELLDIR="/home/binzo/myshell"

# Source all of the sh files under the path param1. It's not recursive.
# Source指定路径param1下所有sh文件，不是递归的。
# param1: specify the path to source.
# param1: 指定要source的路径。
function my_source()
{
    if [ -z "$1" ]; then
        echo -e "\\033[31m参数错误！［Function:my_source of SourceMyShell.sh］\\033[0m"
        return 0
    fi
    for file in `ls $1`; do
        source "$1/$file"
    done
}

# source the files in MYSHELLDIR/utils/
# source目录utils下的文件。
my_source $MYSHELLDIR/utils

# Source the files in MYSHELLDIR/bash_completion.d/
# For enable the args auto completion when I input my own commands.
# source目录bash_completion.d下的所有文件。
# 为了能够在我键入自己的命令时有参数自动补全功能。
my_source $MYSHELLDIR/bash_completion.d

# alias check returned error number from function.
alias chk_return='if (( 0 != $? )); then return 1; fi'

# Commands.
MYCOMMANDDIR=$MYSHELLDIR/commands
alias c='source $MYCOMMANDDIR/cd $*'
alias g='source $MYCOMMANDDIR/grep $*'
alias f='source $MYCOMMANDDIR/find $*'
alias v='source $MYCOMMANDDIR/vim $*'
# costomize command 'nautilus'
alias n='source $MYCOMMANDDIR/nautilus $*'

# kt
MYKTSH=$MYSHELLDIR/kt
source $MYKTSH/repo
alias put='source $MYKTSH/put $*'
alias get='source $MYKTSH/get $*'
alias merge='source $MYKTSH/merge $*'
alias kt='source $MYKTSH/kt $*'
alias rm-='source $MYKTSH/rm $*'
alias mm-='source $MYKTSH/mm $*'

# ftp servers:
alias 99='nautilus ftp://10.10.100.99/liubzh'
alias 100='nautilus ftp://10.10.100.100/liubzh'
alias 90='source $MYKTSH/90 $*'

# Other
alias cq='clearquest &'
alias vnccfg='vncconfig &'
