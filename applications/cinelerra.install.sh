#!/bin/bash
# Created by liubingzhao.

# Cinelerra是一款Linux平台上出色的音视频编辑工具。
# 以下安装方式需要sudo来运行。

# Download / Unpack
mkdir -p /opt/cinelerra
cd /opt/cinelerra
TARBALL=cinelerra-5.0-ubuntu-14.04.1-x86_64-20151221-static.txz
wget -P `pwd` http://cinelerra.org/2015/downloads/$TARBALL
tar -xJf  $TARBALL

# To start Cinelerra simply: ...
# /opt/cinelerra/cinelerra
