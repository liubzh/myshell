#!/bin/bash

# 如果系统是64位，请先开启32位架构支持
sudo dpkg --add-architecture i386

# 安装 wine
sudo add-apt-repository ppa:wine/wine-builds
sudo apt-get update
sudo apt-get install winehq-devel   # 开发分支
# sudo apt-get install winehq-stable   # 稳定分支
# sudo apt-get install winehq-staging   # 暂存分支


# 在线搜索 wineQQ8.9.3_21169.tar.xz，下载 wineQQ 的压缩包
# 解压缩到主目录
# tar xvf wineQQ8.9.3_21169.tar.xz -C ~/
