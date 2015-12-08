repo init -u ssh://10.10.100.21:29418/manifest.git -m stm_L_msm8909_la.1.1_amss_bsp_int.xml --repo-url=ssh://10.10.100.21:29418/repo.git --repo-branch=master --no-repo-verify
repo sync
repo start mybranch --all
tybuild/start tybuild/TBW5767_MAKE.BAT tymake/TBW576711_0002.mk wtprebuilt user
