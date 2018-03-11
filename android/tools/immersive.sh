#!/bin/bash

immersive_type=$1

# 查看当前 policy_control 设置
adb shell settings get global policy_control

if [[ ${immersive_type} == *navigation* ]]; then
    # 隐藏虚拟按键
    #adb shell settings put global policy_control immersive.navigation=apps
    # 排除某个应用
    adb shell settings put global policy_control "immersive.navigation=apps,-com.google.android.apps.nexuslauncher"
elif [[ ${immersive_type} == *status* ]]; then
    # 隐藏状态栏
    #adb shell settings put global policy_control immersive.status=*
    # 排除某个应用
    adb shell settings put global policy_control "immersive.status=apps,-com.google.android.apps.nexuslauncher"
elif [[ ${immersive_type} == *full* ]]; then
    # 隐藏状态栏和虚拟按键
    #adb shell settings put global policy_control "immersive.full=*"
    # 排除某个应用
    adb shell settings put global policy_control "immersive.full=apps,-com.google.android.apps.nexuslauncher,-com.jiongji.andriod.card"
else
    # 恢复
    adb shell settings put global policy_control null
fi

adb shell settings get global policy_control
