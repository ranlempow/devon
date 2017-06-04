# 物件化api

[collect]
1. prepare_failed
2. already exists
3. need install
[running]


### AppDescription
以下每一項都是可選項目

#### entry init()
調整基本環境變數

    not-implement: 猜測合理變數(這個一定要實作)
    in: $REQUIRE_*
    out: $ACCEPT_*
    return-option:
      $ACCEPT_LOCATION 可使用的安裝位置
      $ACCEPT_PATCHES  可使用的補釘
      $DEFAULT_PATCHES 預設會安裝的補釘
      $ALLOW_EMPTY_LOCATION (X把這個設定常態化)使用global作為預設


#### entry versions()
取得版本列表, 也可以直接指定版本

    out : $RELEASE_URL 下載此檔作為versions-file
    return: RELEASE_LIST | versions-file 版本列表


#### entry prepare()
準備安裝所需資訊, 產生依賴表

    in: $MATCH_*
    out: (X)$DEPENDS_URL
    out: $DOWNLOAD_URL_TEMPLATE
    return: (X)$DEPENDS_LIST | depends-file 依賴表
    return: $DOWNLOAD_URL  主檔案下載位址
    return: $TARGET
    return: $APPVER
    return: $APPCUSTOMNAME
    not-implement: 無額外依賴

#### entry download()
TODO: 合併到prepare
準備安裝所需檔案

    in: $DOWNLOAD_URL
    in: $DOWNLOAD_FILE
    out: $DOWNLOAD_URL
    return: -> $DOWNLOAD_FILE
    not-implement: 下載檔案$DOWNLOAD_URL -> $DOWNLOAD_FILE

#### entry unpack()
實際安裝

    in: -> $DOWNLOAD_FILE
    in: $REAL_TARGETDIR
    in: $TARGET
    out: $UNPACK_METHOD
    out: $INSTALLER
    return: -> TARGET
    out/return: $SETENV
    not-implement: 用預設方式安裝$INSTALLER

#### entry applypatch()
安裝補釘

    in: $MATCH_PATCHES
    in: $TARGET

#### var validate_script()
驗正app安裝成功, 功能正常

    out: $CHECK_CMD=gradle -v
    out: $CHECK_LINEWORD=Gradle
    out: $CHECK_OK=Gradle %VA_INFO_VERSION%
    return: $VALIDATE_PASS
    not-implement: 無額外驗證功能, 僅檢查資料夾是否存在

#### var remove_script()
刪除app需要做的事情

    not-implement: 直接刪除資料夾

#### var setenv_script()

    not-implement: none

#### var clearenv_script()

    not-implement: 刪除setenv所設定的物件


#### var beforemove_script()
移動之前要做的事情

    not-implement: none

#### var aftermove_script()
移動之後要做的事情

    not-implement: none



## Process Of Command


#### App Creation Command
| name          | process
|-----------------------
| show          | init
| versions      | init, versions
| designate     | init, designate-versions
| collect,dryrun| [versions|designate], prepare
| download      | [collect], download
| install       | [download], unpack, applypatch, [afterinstall]
| -afterinstall | genenv, aftermove(setenv), set(setenv), validate(setenv)


#### App Manipulation Process
| name          | process
|-----------------------
| applypatch    | init, applypatch, [afterinstall]
| uninstall     | beforemove(setenv), remove(setenv), delete
| upgrade       | [install], [uninstall]
| test          | set(setenv), validate(setenv)
| switch        | [deselect other], set(setenv)
| deselect      | clear(setenv)
| move(rename)  | beforemove(setenv), move, [afterinstall]


#### ??? App Function Process(no argument)
| name          | process
|-----------------------
| uninstall     | search-app, [uninstall]
| upgrade       | search-app, [upgrade]
| select        | search-app, [select]
| deselect      | list-app

#### General Management Process
| name          | process
|-----------------------
| list          | search-app, [info]
| search        |
| status        | list-app, [test], [depends]
| update(all)   | read-spec, [upgrade]
| cache         |
| scope(namesps)|


## Arguments Of Command

General Options:
```
  -v, --version           Show version and exit.
  -V, --verbose           Give more output. Option is additive, and can be
                          used up to 3 times.
  -q, --quiet             Only output important information
  -s, --silent            Do not output anything, besides errors
  -f, --force             Makes various commands more forceful
  -y, --yes
  --allow-root            Allows running commands as root
  --no-color              Disable colors

  --cache-dir             Folder for caching downloaded file
  --output-dir            Folder for Spces-file and depends-file
  --log-file              The Logging file with detail
```

App Common options:
```
  -S, --save              Package will appear in your dependencies
  -D, --save-dev          Package will appear in your devDependencies
  -O, --save-optional     Package will appear in your optionalDependencies
  -E, --save-exact        Saved dependencies will be configured with an exact
                          version rather than using npm's default semver range operator
  -U, --save-user
```

#### App Creation Command
```
info <spec>
versions <spec>
depends <spec>
download <spec>
install <spec> [app common options] [--deselect]
```

#### App Manipulation Process
```
uninstall <spec>|<path> [app common options]
upgrade <spec>|<path> [<upgrade-spec>] [app common options]
test <spec>|<path>
select <spec>|<path> [app common options]
deselect <spec>|<path> [app common options]
move <spec>|<path> <target-path>
```

#### App Function Process(no argument)
```
uninstall [app common options]
upgrade [app common options]
select
deselect
```

#### General Management Process
```
list [--local] [--global] [--system]
status [--local] [--global] [--system] [--not-only-selected]
update [<specs-file>]
cache clear|list
```







### 版本指定
1. app[=ver][@arch][[patches]]
2. app[=ver][_arch][[(patch,)*]][@locaction][-selection][-no-env][-shim]
3. app[=ver][_arch][[(patch-)*]][(-option)*]
4. [NAME][SPEC][OPTIONS]
app1=3.1.X_x86[-]-global-select
app1--3.1.X_x86[-]-global-select
(X) venvname@venv[venvpatch]--name@host=3.1.X_x64[default]
name@host:3.1.X_x64[default]*local*no-select
name@host-venv:3.1.X_x64[default]*local*no-select

### APP指定
1. 版本指定
2. 路徑指定

### 升級指定
1. 版本指定
2. -.-.X


### inner call
inner call 不會進入保護模式, 所以輸出變數會保留

dev-sh api FUNCTION args...

主要的api是
1.取得devon.ini的內容
    FindConfigs 取得所有devon.ini的路徑
    GetIniArray area files...
    GetIniPairs area files...
    GetIniValue area keys files...
    IterValues text spliter loopCb
    IterPairs text spliter1 spliter2 loopCb
4.donwload, unzip, basic-file-op
    BrickvDownload
    Unzip
    UnpackMsi
    InstallMsi
    MoveFile

5.brickv
6.plugin
    CallHook
    Reload?
    LoadPlugin?

3.error處理(這不是API但是規格的一部分)
    Raise
    IgnoreError

2.print功能(格式化)(logging)
    ImportColorTable
    PrintMsg
    PrintError



### plugin架構
資料夾底下有
1. hooks: devhook-update.cmd
2. cmds: devcmd-foo.cmd
3. env: env.cmd
4. ini: devon.ini
5. repo: brick-bar.cmd


plugin可以用以下方式安裝
1. 用git clone方式安裝在全域
2. 用下載方式安裝在專案資料夾, 並且commit進版本庫
3. 用git submodule安裝在專案資料夾

