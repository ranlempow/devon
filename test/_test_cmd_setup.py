# noqa: V, D

import os
import sys
import unittest
import shutil

from .utils import ScriptTestCase, Removed

class Test(ScriptTestCase):
    target = 'CMD_setup.cmd'

    def test_CMD_setup(self):
        os.system('git init {}'.format(self.testdir))
        self.script.call('CMD_setup', ['--username', 'testname', '--githubtoken', 'abc=123'],
                    env={'HOME':'.home', 'PATH':'C:\\Program Files (x86)\\Git\\cmd'}).assertResult(
            self, added={})

        self.assertEqual(
            open(os.path.join(self.testdir, '.home', '_netrc')).read(),
            """machine github.com
login abc
password 123

machine api.github.com
login abc
password 123

""")
        gitconfig = open(os.path.join(self.testdir, '.git', 'config')).read()
        self.assertTrue('name = testname' in gitconfig)
        self.assertTrue('email = testname@users.noreply.github.com' in gitconfig)

        # test AlreadySetup
        self.script.call('CMD_setup', ['--username', 'badname', '--githubtoken', 'def=456'],
                    env={'HOME':'.home', 'PATH':'C:\\Program Files (x86)\\Git\\cmd'}).assertResult(
            self, added={})

        self.assertTrue('name = testname' in gitconfig)
        self.assertTrue('email = testname@users.noreply.github.com' in gitconfig)
