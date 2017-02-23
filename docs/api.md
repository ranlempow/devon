[-$get-args]

$versions(URL, REGEX)
    download version file and parser it
[-$fetchver]

[-$semver]


$require(SPEC, runtime=N)
    set requirement of this app

[-$resolve]


$appver VERNAME
$installer(URL, FILENAME, MSI=N)
    set installer file name and its parent url

[-$before-install]
[-$auto-install]

-$download
    download file
-$movepath
    move file
-$unzip
    unzip file
-$msi-execute
    msi file

$env-set VAR=VALUE
$env-path PATH
$check --cmd CMD --line-word WORD --match MATCH
$check --path PATH
$check --bin PATH
[-$gen-env]
[-$job-exit]

[-$search-apps]
[-$list-apps]
-$print
    print message

目前只有gradle是完成度高的
其他的請參考gradle的格式來完成


manage
=================================
brickv <command> [<args>] [<options>]

install [<app-list>] [<options>] [<app-list>] [<options>]
  -a, --all               Install all the apps listed in profile
  --switch
  --save

uninstall                 simply remove
  -a, --all               Uninstall all the apps listed in profile
  -y, --yes               Don't confirmation

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
system


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

