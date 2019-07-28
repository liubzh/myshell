#!/bin/bash

DIR=$(dirname $0)

KILL_DIR=/data/local/tmp/kill
adb shell <<!
if [ ! -f "${KILL_DIR}" ]; then
    mkdir -p "${KILL_DIR}"
fi
!

KILL_SH_FILE=${KILL_DIR}/kill.sh
PACKAGE_LIST_FILE=${KILL_DIR}/packages.list

adb push ${DIR}/packages.list ${KILL_DIR}
adb push ${DIR}/kill.sh ${KILL_DIR}

function changePerm() {
adb shell <<!
su

chgrp root ${KILL_SH_FILE}
chown root ${KILL_SH_FILE}

chgrp root ${PACKAGE_LIST_FILE}
chown root ${PACKAGE_LIST_FILE}

chmod +x ${KILL_SH_FILE}
chgrp root ${KILL_SH_FILE}
chown root ${KILL_SH_FILE}

exit
!
}

#changePerm
