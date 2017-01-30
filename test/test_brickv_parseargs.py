# noqa: V, D

import os
import sys
import unittest
import shutil

from .utils import ScriptTestCase


class Test(ScriptTestCase):
    target = 'brickv_prepare.cmd'

    def _default_envs(self):
        return {
            'VERSION_SPCES_FILE': 'C:\\Users\\ran\\AppData\\Local\\Temp\\version_spces.txt',
            # 'DRYRUN':
            'FORCE': '0',
            # 'CHECKONLY':
            # 'NOCHECK':
            'NO_COLOR': '0',
            'LOG_LEVEL': '3',
            'REQUEST_SPEC': '=x@x86[.]',
            # 'REQUEST_APP':
            # 'REQUEST_MAJOR':
            # 'REQUEST_MINOR':
            # 'REQUEST_PATCH':
            'REQUEST_ARCH': 'x86',
            'REQUEST_PATCHES': '.',
            'REQUEST_VER': 'x',
        }

    def test_BrickvPrepare(self):
        self.script.call('BrickvPrepare', []).assertResult(
            self, added=self._default_envs())
