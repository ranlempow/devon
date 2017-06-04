# noqa: V, D

import os
import sys
import unittest

from .utils import ScriptTestCase, Removed


class Test(ScriptTestCase):
    target = 'print.cmd'

    def test_PrintMsg(self):
        self.box.call('PrintMsg', ['error', 'msg', 'body']).assertSuccess(
            stdout=['brickv msg "body"'])

    def test_PrintMsg_no_display(self):
        self.box.call('PrintMsg', ['info', 'msg', 'body']).assertSuccess()
