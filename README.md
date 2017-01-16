Binzo's own shell scripts

How to enable myshell?
Execute the file init.sh will enable myshell.

commands:
Command	      | Description
--------------|--------------
adb           | Completing argument for adb push and so on.
add-phone     | Binzo's command to add usb access permission to file /etc/udev/rules.d/51-android.rules.
cd            | Binzo's customized 'cd' command.
find          | Binzo's customized 'find' command.
grep          | Binzo's customized 'grep' command.
switch-git    | Binzo's command for switching different git version.
switch-locale | Binzo's command for switching locale, it changes env variable LANG.
switch-proj   | Binzo's command for switching gn project.
vim           | Binzo's customized 'vim' command.

bash_completion.d:
File          | Description
--------------|--------------
adb           | Binzo's completion script for command adb.
f             | Binzo's completion script for command f.
g             | Binzo's completion script for command g.
switch-proj   | Binzo's completion script for command switch-proj.
TmakeGionee   | Binzo's completion script for command TmakeGionee.
v             | Binzo's completing script for command v.

sh:
File          | Description
--------------|--------------
lottery.sh    | Binzo's shell script for choosing item(s) randomly.