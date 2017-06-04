# noqa: V, D

import os
import sys
import unittest
import shutil
import time
import subprocess

from os.path import join
from subprocess import check_call

from .utils import ScriptTestCase, Removed


class Test(ScriptTestCase):
    target = 'CMD_sync.cmd'

    @classmethod
    def setUpClass(cls):
        super().setUpClass()

        # make center repository
        cls.repo = cls.subdir('repo')
        check_call('git init --bare {}'.format(cls.repo))

        # make first commit
        cls.origin = join(cls.testdir, 'origin')
        time.sleep(0.3)
        check_call('git clone {} {}'.format(cls.repo, cls.origin))
        os.chdir(cls.origin)
        open('file1.txt', 'w').write('contentA')
        check_call('git add -A')
        os.system('git commit -m "first"')
        check_call('git push -u origin master')

        # make projects
        cls.prjff = join(cls.testdir, 'project_fast_forward')
        check_call('git clone {} {}'.format(cls.repo, cls.prjff))

        cls.prjmerge = join(cls.testdir, 'project_merge')
        check_call('git clone {} {}'.format(cls.repo, cls.prjmerge))

        cls.prjconflict = join(cls.testdir, 'project_conflict')
        check_call('git clone {} {}'.format(cls.repo, cls.prjconflict))

        # make second commit
        open('file1.txt', 'w').write('contentB')
        check_call('git add -A')
        os.system('git commit -m "second"')
        check_call('git push')

    def git_log(self, cwd):
        p = subprocess.Popen('git log --oneline', cwd=cwd, stdout=subprocess.PIPE)
        output = p.stdout.read().decode('utf-8')
        output = [ln[8:] for ln in reversed(output.split('\n')) if ln]
        return output

    def test_CMD_sync_fast_forward(self):
        self.script.call('CMD_sync', [], cwd=self.prjff)
        gitlog = self.git_log(self.prjff)
        self.assertEqual(gitlog, ['first', 'second'])

    def test_CMD_sync_merge(self):
        os.chdir(self.prjmerge)
        open('file2.txt', 'w').write('content2')
        check_call('git add -A')
        os.system('git commit -m "third 2"')

        self.script.call('CMD_sync', [], cwd=self.prjmerge)
        gitlog = self.git_log(self.prjmerge)
        self.assertEqual(gitlog, ['first', 'second', 'third 2'])

    def test_CMD_sync_conflict(self):
        os.chdir(self.prjconflict)
        open('file1.txt', 'w').write('contentC')
        check_call('git add -A')
        os.system('git commit -m "third C"')

        self.script.call('CMD_sync', [], cwd=self.prjconflict)
        gitlog = self.git_log(self.prjconflict)
        self.assertEqual(gitlog, ['first', 'second', 'third C',
                                  "Merge branch 'master' of " + self.repo])
