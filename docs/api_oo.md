# 物件化api

### AppDescription
以下每一項都是可選項目

#### entry init()
調整基本環境變數

    not-implement: 猜測合理變數(這個一定要實作)

#### entry detect()
檢查環境是否符合(暫不實作)

    in: $REQUIRE_*
    out: $ACCEPT_*
    return-option: $ACCEPT
    not-implement: 假設合理環境, 使用$ACCEPT_*做檢查

#### entry versions()
取得版本列表

    out : $RELEASE_URL 下載此檔作為versions-file
    return: RELEASE_LIST | versions-file 版本列表

    not-implement: 直接指定版本

#### entry prepare()
準備安裝所需資訊, 產生依賴表

    in: $MATCH_*
    out: $DEPENDS_URL
    out: $DOWNLOAD_URL_TEMPLATE
    return: $DEPENDS_LIST | depends-file 依賴表
    return: $DOWNLOAD_URL  主檔案下載位址
    return: $TARGET
    not-implement: 無額外依賴

#### entry download()
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

#### entry validate()
驗正app安裝成功, 功能正常

    out: $CHECK_CMD=gradle -v
    out: $CHECK_LINEWORD=Gradle
    out: $CHECK_OK=Gradle %VA_INFO_VERSION%
    return: $VALIDATE_PASS
    not-implement: 無額外驗證功能, 僅檢查資料夾是否存在

#### entry remove()
刪除app需要做的事情

    not-implement: 直接刪除資料夾

#### entry setenv()

    not-implement: none

#### entry clearenv()

    not-implement: 刪除setenv所設定的物件


#### entry beforemove()
移動之前要做的事情

    not-implement: none

#### entry aftermove()
移動之後要做的事情

    not-implement: none



### AppPatch
#### entry detect()
#### entry prepare()
#### entry unpack()
#### entry remove()



## Process Of Command


#### App Creation Command
| name          | process
|-----------------------
| info          | init
| versions      | init, versions
| depends(dryrun)| init, versions, prepare
| download      | [dependency], download
| install       | [dependency], download, unpack, aftermove, [test]

#### App Manipulation Process
| name          | process
|-----------------------
| uninstall     | init, beforemove, remove, [delete]
| upgrade       | [install], [uninstall]
| test          | init, setenv, validate
| select        | init, [deselect other], setenv
| deselect      | init, clearenv
| move          | init, beforemove, [copy], aftermove, setenv, validate

#### App Function Process(no argument)
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

### APP指定
1. 版本指定
2. 路徑指定

### 升級指定
1. 版本指定
2. -.-.X

