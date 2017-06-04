# noqa: V, D
import os
import unittest

from .utils import ScriptTestCase, Removed
from scripts.shellexec import ScriptExecution  # noqa: U


class Test(ScriptTestCase):
    target = 'brickv_genenv.cmd'

    def test_GenEnv_basic(self):
        testdir = self.subdir('basic')
        setenv_file = os.path.join(testdir, 'set-env.cmd')
        self.script.call('BrickvGenEnv', [testdir, 'app1', '1.0.0']).assertResult(
            self, stdout="")

        setenv_exec = ScriptExecution(setenv_file[:-4], args=['--set'], env=None).run()
        setenv_exec.assertResult(
            self, stdout="", added={
                'VA_APP1_BASE': 'C:\\Users\\ran\\Desktop\\brickv\\var\\brickv_genenv\\basic'})

        setenv_exec = ScriptExecution(setenv_file[:-4], args=['--info'], env=None).run()
        setenv_exec.assertResult(
            self, stdout="", added={'VA_INFO_APPNAME': 'app1', 'VA_INFO_VERSION': '1.0.0'})

    def test_GenEnv_clear(self):
        testdir = self.subdir('clear')
        setenv_file = os.path.join(testdir, 'set-env.cmd')
        self.script.call('BrickvGenEnv', [testdir, 'app1', '1.0.0']).assertResult(
            self, stdout="")

        env = os.environ.copy()
        env.update({"VA_APP1_BASE":"C:\\Users\\ran\\Desktop\\brickv\\var\\brickv_genenv\\clear"})

        setenv_exec = ScriptExecution(setenv_file[:-4], args=['--clear'], env=env).run()
        setenv_exec.assertResult(
            self, stdout="", removed={
                'VA_APP1_BASE':"C:\\Users\\ran\\Desktop\\brickv\\var\\brickv_genenv\\clear"})

    def test_GenEnv_validate(self):
        testdir = self.subdir('validate')
        setenv_file = os.path.join(testdir, 'set-env.cmd')
        env = os.environ.copy()
        env.update({"CHECK_EXIST":"set-env.cmd"})
        self.script.call('BrickvGenEnv', [testdir, 'app1', '1.0.0'],
                         env=env).assertResult(
            self, stdout="")

        setenv_exec = ScriptExecution(setenv_file[:-4], args=['--validate'], env=None).run()
        setenv_exec.assertResult(self, stdout="", ret=0)


    def test_GenEnv_validate_excepted_fail(self):
        testdir = self.subdir('validate_excepted_fail')
        setenv_file = os.path.join(testdir, 'set-env.cmd')
        env = os.environ.copy()
        env.update({"CHECK_EXIST":"not-exist.cmd"})
        self.script.call('BrickvGenEnv', [testdir, 'app1', '1.0.0'],
                         env=env).assertResult(
            self, stdout="")

        setenv_exec = ScriptExecution(setenv_file[:-4], args=['--validate'], env=None).run()
        setenv_exec.assertResult(self, stdout="", ret=1, added={
            'VALID_ERR': 'C:\\Users\\ran\\Desktop\\brickv\\var\\brickv_genenv\\validate_excepted_fail\\not-exist.cmd not exist'
            })
