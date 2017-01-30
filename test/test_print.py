# noqa: V, D

import os
import sys
import unittest

from .utils import ScriptTestCase


class Test(ScriptTestCase):
    target = 'print.cmd'

    def test_PrintMsg(self):
        self.script.call('PrintMsg', ['error', 'msg', 'body']).assertResult(
            self, stdout='brickv msg "body"\r\n')

    def test_PrintMsg_no_display(self):
        self.script.call('PrintMsg', ['info', 'msg', 'body']).assertResult(
            self, stdout='')
