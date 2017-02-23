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
            # 'DRYRUN':
            'FORCE': '0',
            'LOCAL_DIR': 'C:\\Users\\ran\\AppData\\Local\\Programs',
            # 'CHECKONLY':
            # 'NOCHECK':
            'NO_COLOR': '0',
            'LOG_LEVEL': '3',
            'REQUEST_LOCATION': 'global',
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
        result = self.script.call('BrickvPrepare', [])
        result.assertResult(
            self, added=self._default_envs())

    def test_BrickvPrepareOptions(self):
        result = self.script.call('BrickvPrepare', ['--force', '--dry', '--no-check',
                                                    '--no-color', '--vv'])
        basic = self._default_envs()
        basic.update({
            'FORCE': '1',
            'DRYRUN': '1',
            'NOCHECK': '1',
            'NO_COLOR': '1',
            'LOG_LEVEL': '1',
        })
        result.assertResult(
            self, stdout=None, added=basic)

    def test_BrickvPrepare2(self):
        result = self.script.call('BrickvPrepare', ['--spec', 'app=1.2'])
        basic = self._default_envs()
        basic.update({
            'REQUEST_SPEC': 'app=1.2@any[.]',
            'REQUEST_APP': 'app',
            'REQUEST_MAJOR': '1',
            'REQUEST_MINOR': '2',
            'REQUEST_PATCH': 'x',
            'REQUEST_ARCH': 'any',
            'REQUEST_PATCHES': '.',
            'REQUEST_VER': '1.2',
        })
        result.assertResult(
            self, added=basic)
