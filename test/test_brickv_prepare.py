# noqa: V, D
import os
import unittest

from .utils import ScriptTestCase, Removed


class Test(ScriptTestCase):
    target = 'brickv_prepare.cmd'

    def test_BrickvPrepare_basic(self):
        self.script.call('BrickvPrepare', ['=x']).assertResult(
            self, stdout='', added={
                'BRICKV_GLOBAL_DIR': 'C:\\Users\\ran\\AppData\\Local\\Programs',
                'BRICKV_LOCAL_DIR': 'C:\\Users\\ran\\Desktop\\brickv\\var\\brickv_prepare',
                'LOG_LEVEL': '3',
                'REQUEST_SPEC': '=x',
            })

        self.script.call('BrickvPrepare', ['=x', '--debug', '--local-dir', 'C:\\']).assertResult(
            self, stdout='', added={
                'BRICKV_GLOBAL_DIR': 'C:\\Users\\ran\\AppData\\Local\\Programs',
                'BRICKV_LOCAL_DIR': 'C:\\',
                'LOG_LEVEL': '1',
                'REQUEST_SPEC': '=x',
            })

        self.script.call('BrickvPrepare', ['app=2.3', '--silent', '--local']).assertResult(
            self, stdout='', added={
                'BRICKV_GLOBAL_DIR': 'C:\\Users\\ran\\AppData\\Local\\Programs',
                'BRICKV_LOCAL_DIR': 'C:\\Users\\ran\\Desktop\\brickv\\var\\brickv_prepare',
                'REQUEST_LOCATION': 'local',
                'LOG_LEVEL': '5',
                'REQUEST_SPEC': 'app=2.3',
            })
