# noqa: V, D
import os
import sys
import unittest

from .utils import ScriptTestCase


class Test(ScriptTestCase):
    target = 'project-paths.cmd'

    def test_LoadConfigPaths_nofile(self):
        testdir, script = self.subscript('LoadConfigPaths_nofile')
        script.call('LoadConfigPaths', []).assertResult(
            self, added={
                'PRJ_ROOT': testdir,
                'PRJ_BIN':  testdir + '\\bin',
                'PRJ_CONF': testdir + '\\config',
                'PRJ_LOG':  'C:\\Users\\ran\\AppData\\Local\\Temp\\devon-LoadConfigPaths_nofile\\log',
                'PRJ_TMP':  'C:\\Users\\ran\\AppData\\Local\\Temp\\devon-LoadConfigPaths_nofile\\tmp',
                'PRJ_VAR':  'C:\\Users\\ran\\AppData\\Local\\Temp\\devon-LoadConfigPaths_nofile'
            })

    def test_LoadConfigPaths_hasdir(self):
        testdir, script = self.subscript('LoadConfigPaths_hasdir')
        self.subdir(testdir, 'var')
        self.subdir(testdir, 'tmp')
        script.call('LoadConfigPaths', []).assertResult(
            self, added={
                'PRJ_ROOT': testdir,
                'PRJ_BIN':  testdir + '\\bin',
                'PRJ_CONF': testdir + '\\config',
                'PRJ_LOG':  testdir + '\\var\\log',
                'PRJ_TMP':  testdir + '\\tmp',
                'PRJ_VAR':  testdir + '\\var'
            })

    def test_LoadConfigPaths_basic(self):
        testdir, script = self.subscript('LoadConfigPaths_basic')
        inifile = os.path.join(testdir, 'devon.ini')
        with open(inifile, 'w', encoding='utf-8') as fp:
            fp.write('''
[layout]
bin=t_bin
var=t_var
            ''')
        script.call('LoadConfigPaths', []).assertResult(
            self, added={
                'DEVON_CONFIG_PATH': testdir + '\\devon.ini',
                'PRJ_ROOT': testdir,
                'PRJ_BIN':  testdir + '\\t_bin',
                'PRJ_CONF': testdir,
                'PRJ_LOG':  testdir + '\\t_var\\log',
                'PRJ_TMP':  testdir + '\\t_var\\tmp',
                'PRJ_VAR':  testdir + '\\t_var'
            })
