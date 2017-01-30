# noqa: V, D

import os
import sys
import unittest

from .utils import ScriptTestCase


class TestParseIni(ScriptTestCase):
    target = 'parseini.cmd'

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.inifile = os.path.join(cls.testdir, 'test.ini')
        with open(cls.inifile, 'w', encoding='utf-8') as fp:
            fp.write('''
[area1]
attr1=123
attr2=456

[array]
ab
cd
ef
            ''')


    def test_GetIniValue(self):
        self.script.call('GetIniValue', ['test.ini', 'area1', 'attr1']).assertResult(
            self, added={'INIVAL': '123'})

    def test_GetIniArray(self):
        self.script.call('GetIniArray', ['test.ini', 'array']).assertResult(
            self, added={'INIVAL': 'ab;cd;ef'})

    def test_GetIniPairs(self):
        self.script.call('GetIniPairs', ['test.ini', 'area1']).assertResult(
            self, added={'INIVAL': 'attr1=123;attr2=456'})
