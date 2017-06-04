# noqa: V, D

import os
import sys
import unittest

from .utils import ScriptTestCase, Removed


inidata = b'''
[area1]
attr1=123
attr2=456

[array]
ab
cd
ef
'''

class TestParseIni(ScriptTestCase):
    target = 'parseini.cmd'

    def test_GetIniValue(self):
        self.box.write('test.ini', inidata)
        self.box.call('GetIniValue', ['test.ini', 'area1', 'attr1']
               ).assertSuccess().assertEnv(INIVAL='123')

    def test_GetIniArray(self):
        self.box.write('test.ini', inidata)
        self.box.call('GetIniArray', ['test.ini', 'array']
               ).assertSuccess().assertEnv(INIVAL='ab;cd;ef')

    def test_GetIniPairs(self):
        self.box.write('test.ini', inidata)
        self.box.call('GetIniPairs', ['test.ini', 'area1']
               ).assertSuccess().assertEnv(INIVAL='attr1=123;attr2=456')

