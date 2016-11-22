## 主要的目錄

| var           | default        | require | automation | gitignore
|-----------------------
| $PRJ_ROOT     | /              | - | - | -
| $PRJ_BIN      | /bin           |   | O | O
| $PRJ_TOOLS    | /tools         | O | O | 
| $PRJ_CONF     | /config        | O |   | 
| $PRJ_VAR      | /var           | A | ? | O
| $PRJ_EXT      | /external      |   | O | submodule
| $PRJ_SRC      | /src           | O |   | 
| $PRJ_TEST     | /test          |   |   | 
| $PRJ_DOCS     | /docs          |   | ? | 
| $PRJ_LOG      | $PRJ_VAR/log   |   | O | O


## $PRJ_ROOT
`/`
[editor]: .sublime-project
[proj]: project.json
[ci]: .travis.yml
.editorconfig
.gitignore
.gitattributes
.gitmodules
dev-sh
dev-sh.cmd
README.md
LICENSE


## $PRJ_BIN
`/bin`
X not-readonly(開發人員修改此處檔案)
X git(提交到版本控制)
可執行程式, 通常是二進位檔
或是一些快取的放置處
`/bin/.cache`


## $PRJ_TOOLS
`/tools` `/utils`
X not-readonly(開發人員修改此處檔案)
O git(提交到版本控制)
可執行程式, 通常是腳本
`/tools/brickv` - 控制apps的程式
`/tools/brickv/one/core` - one的核心控制程式
`/tools/brickv/one/plugins` - one的外掛程式


## $PRJ_CONF
`/config` `/scripts`
O not-readonly(開發人員修改此處檔案)
O git(提交到版本控制)
bin或tools的設定檔, 或是一些腳本檔, 會被提交到版本控制
`/config/[app]`
`/config/private/[app]`


## <build>
`/build` `/config/build` `/scripts/build`
O not-readonly(開發人員修改此處檔案)
O git(提交到版本控制)
建造用的腳本


## $PRJ_DOCS
`/docs` `/doc`
會被提交到版本控制的各種文件通常是markdown格式
`/docs/samples`


## $PRJ_SRC
`/src` `/lib` `/$PROJECT_NAME` `/apps`
原始檔資料夾, 採用maven結構
`/src/[package]`
`/src/[language]/[package]`
`/src/[target]/[language]/[package]`


## $PRJ_VAR
`/var` `/stage` `/objs` 
X not-readonly(開發人員修改此處檔案)
X git(提交到版本控制)
建造過程的中間產物
或是因為測試而產生的產物
`/var/temp`
`/var/lib`


## <dist>
/dist /artifacts
X not-readonly(開發人員修改此處檔案)
X git(提交到版本控制)
編譯後的最終檔案


## $PRJ_EXT
`/external` `/thirdparty` `/libs` `/apps/lib`
X not-readonly(開發人員修改此處檔案)
O git(提交到版本控制)
外部檔案


## $PRJ_TEST
`/test` `/tests`
非屬原始碼一部分的測試


## $PRJ_LOG
`/log` `/var/log`
X not-readonly(開發人員修改此處檔案)
X git(提交到版本控制)
記錄檔的存放區


## <IDE 設定檔>
有兩可以方的地方
/[.ide] 必用
/config/[ide]/[.ide] 選用
/config/private/[ide]/[.ide] 私用


## <Project 設定檔>
/[.proj] 最推薦的地點
/config/[proj]/[.proj]
/build/[proj]/[.proj]

