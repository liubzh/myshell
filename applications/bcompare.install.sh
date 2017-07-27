#!/bin/bash

# 在官网查看最新 release 版本：http://www.scootersoftware.com/download.php?zz=kb_linux_install
wget http://www.scootersoftware.com/bcompare-4.2.2.22384_amd64.deb
sudo apt-get update
sudo apt-get install gdebi-core
sudo gdebi bcompare-4.2.2.22384_amd64.deb
