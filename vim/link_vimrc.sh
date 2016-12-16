#!/bin/bash
# Author:liubingzhao

MY_VIM_DIR=$MYSHELLDIR/vim
MY_VIMRC=$MY_VIM_DIR/vimrc
VIMRC=~/.vimrc
if [ ! -f $VIMRC ]; then
    ln -s $MY_VIMRC $VIMRC # Link .vimrc file.
    echoI link .vimrc successfully.
else
    echoW .vimrc exists already.
fi
