#!/bin/bash

pushd /tmp > /dev/null
cmd="wget https://dl.winehq.org/wine-builds/Release.key"
echo ${cmd}; ${cmd}
cmd="sudo apt-key add Release.key"
echo ${cmd}; ${cmd}
cmd="sudo apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/"
echo ${cmd}; ${cmd}
popd > /dev/null

cmd="sudo apt-get update"
echo ${cmd}; ${cmd}
cmd="sudo apt-get install winehq-devel"
echo ${cmd}; ${cmd}

# 解压程序包
