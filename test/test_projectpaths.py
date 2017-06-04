# noqa: V, D
import os
import sys
import unittest

from .utils import ScriptTestCase, Removed


class Test(ScriptTestCase):
    target = 'project-paths.cmd'

    def test_LoadConfigPaths_nofile(self):
        with self.box.subcase('LoadConfigPaths_nofile', push=True) as box:
            box.call('LoadConfigPaths', []).assertSuccess().assertEnv(
                PRJ_ROOT=box.getpath(),
                PRJ_BIN=box.getpath('bin'),
                PRJ_CONF=box.getpath('config'),
                PRJ_LOG=box.absjoin('${TEMP}', 'devon-LoadConfigPaths_nofile/log'),
                PRJ_TMP=box.absjoin('${TEMP}', 'devon-LoadConfigPaths_nofile/tmp'),
                PRJ_VAR=box.absjoin('${TEMP}', 'devon-LoadConfigPaths_nofile'),
            )

    def test_LoadConfigPaths_hasdir(self):
        with self.box.subcase('LoadConfigPaths_hasdir', push=True) as box:
            box.makedir('var')
            box.makedir('tmp')
            box.call('LoadConfigPaths', []).assertSuccess().assertEnv(
                PRJ_ROOT=box.getpath(),
                PRJ_BIN=box.getpath('bin'),
                PRJ_CONF=box.getpath('config'),
                PRJ_LOG=box.getpath('var/log'),
                PRJ_TMP=box.getpath('tmp'),
                PRJ_VAR=box.getpath('var'),
            )

    def test_LoadConfigPaths_basic(self):
        with self.box.subcase('LoadConfigPaths_basic', push=True) as box:
            box.makedir('var')
            box.makedir('tmp')
            box.write('devon.ini', b'''
[layout]
bin=t_bin
var=t_var
''')
            box.call('LoadConfigPaths', []).assertSuccess().assertEnv(
                DEVON_CONFIG_PATH=box.getpath('devon.ini'),
                PRJ_ROOT=box.getpath(),
                PRJ_BIN=box.getpath('t_bin'),
                PRJ_CONF=box.getpath(),
                PRJ_LOG=box.getpath('t_var/log'),
                PRJ_TMP=box.getpath('tmp'),
                PRJ_VAR=box.getpath('t_var'),
            )

