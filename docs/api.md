
manage
=================================
brickv <command> [<args>] [<options>]

install [<app-list>] [<options>] [<app-list>] [<options>]
  -a, --all               Install all the apps listed in profile
  --no-switch
  --save

uninstall                 simply remove
  -a, --all               Uninstall all the apps listed in profile
  -y, --yes               Don't confirmation

upgrade

switch/enable
  --save
  -i, --no-interact
disable
  --save
  -i, --no-interact




application
=================================




set-env
=================================
set-env [<options>]
Options:
  --no-color              Disable colors
  --set                   Enter environment for this app (defalut action)
  --clear                 Exit environment for this app
  --patch-moved           Should use after moving app base folder
  --info                  Show information
  --validate              Check properly installed
  --upgrade               使用者自己重新安裝??

同一個應用程式只能夠同時間 '--set' 其中一個, 後來啟用的會把前一個版本給 '--clear'.
'--validate'加上'--test'可以加跑該應用程式的所有測試案例.
不做--patch-move, 使用者可以自己重新安裝

TODO: 可能要對set-env做shell gaurding
VA_INFO_APPNAME: 應用程式的名稱
VA_INFO_VERSION: 應用程式的版本
VA_INFO_PATCHES: (選用)應用程式所套用的補釘
VA_INFO_DEPENDS: 應用程式所依賴的其他應用程式(目前只允許一個)

@set CHECK_EXIST=
@set CHECK_CMD=ansicon.exe --help
@set CHECK_LINEWORD=Freeware
@set CHECK_OK=Version %VA_INFO_VERSION%




large_dependency
=================================

description
-------------
arch  x86,x64,arm(platform.machine())
system osx, win, linux(platform.system())
version 1.2, 1.3 (semver)
dependency apt...homebrew(semver)


location
-------------
[default]
local
global
(X)system


application
-------------
install - install app
check - check if installed porperly
test - test app functional


configure or setup
-------------
PATH
.env
cmd.cmd(activate.bat)

