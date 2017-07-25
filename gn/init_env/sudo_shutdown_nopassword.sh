#!/bin/bash

TARGET_FILE="/etc/sudoers"

cat << CONFIG
# Added by liubingzhao. begin
%sudo	ALL=(root) NOPASSWD: /sbin/shutdown
# Added by liubingzhao. end'
CONFIG

read -p "复制以上信息，手动粘贴，:wq! 强制保存，按任意键继续..."
sudo vim "${TARGET_FILE}"
