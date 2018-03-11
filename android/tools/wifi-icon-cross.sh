#!/bin/bash

# 网络连接图标有叉号或者叹号，是因为无法访问谷歌网站，更改检查网络有效性的链接：
adb shell settings put global captive_portal_https_url https://www.google.cn/generate_204
