# noqa: V, D
import os
import unittest

from .utils import ScriptTestCase


class Test(ScriptTestCase):
    target = 'semver.cmd'

    def test_MatchVersion_complete_format(self):
        self.script.call('MatchVersion', ['app1']).assertResult(
            self, stdout="app1=x.x.x@any[.]\r\n")

    def test_MatchVersion_cmd_format(self):
        self.script.call('MatchVersion', ['--output-format', 'cmd', 'app1']).assertResult(
            self, stdout="app1 x x x any .\r\n")

    def test_MatchVersion_env_format(self):
        self.script.call('MatchVersion', ['--output-format', 'env', 'app1']).assertResult(
            self, stdout="", added={
                'MATCH_APP': 'app1',
                'MATCH_ARCH': 'any',
                'MATCH_MAJOR': 'x',
                'MATCH_MINOR': 'x',
                'MATCH_PATCH': 'x',
                'MATCH_PATCHES': '.',
                'MATCH_VER': 'x'})
        self.script.call('MatchVersion', ['--output-format', 'env', 'app1=3.2@x86[abc]']).assertResult(
            self, stdout="", added={
                'MATCH_APP': 'app1',
                'MATCH_ARCH': 'x86',
                'MATCH_MAJOR': '3',
                'MATCH_MINOR': '2',
                'MATCH_PATCH': 'x',
                'MATCH_PATCHES': 'abc',
                'MATCH_VER': '3.2'})

    def test_MatchVersion_all(self):
        self.script.call('MatchVersion', ['--all', 'app1=2', 'app1=3', 'app1=2']).assertResult(
            self, stdout="app1=3.x.x@any[.]\r\napp1=2.x.x@any[.]\r\napp1=2.x.x@any[.]\r\n")
        self.script.call('MatchVersion', ['--all', 'app1=1.2.3', 'app1=3.2.1', 'app2=3.2.1']).assertResult(
            self, stdout="app2=3.2.1@any[.]\r\napp1=3.2.1@any[.]\r\napp1=1.2.3@any[.]\r\n")

    def test_MatchVersion_match(self):
        self.script.call('MatchVersion', ['--spec-match', 'app1', 'app1', 'app2']).assertResult(
            self, stdout="app1=x.x.x@any[.]\r\n")
        self.script.call('MatchVersion', ['--spec-match', 'app1=2', 'app1=3', 'app1=2']).assertResult(
            self, stdout="app1=2.x.x@any[.]\r\n")
        self.script.call('MatchVersion', ['--spec-match', 'app1=2', 'app1=3.1', 'app1=2.3']).assertResult(
            self, stdout="app1=2.3.x@any[.]\r\n")
        self.script.call('MatchVersion', ['--spec-match', 'app1@x64', 'app1=3@x86', 'app1=2@x64']).assertResult(
            self, stdout="app1=2.x.x@x64[.]\r\n")

    def test_MatchVersion_specs_file(self):
        specs_file = os.path.join(self.testdir, 'specs_file.txt')
        with open(specs_file, 'w') as fp:
            fp.write('app1=2.x.x@any[.]\napp1=3.x.x@any[.]\napp1=2.x.x@any[.]\n')
        self.script.call('MatchVersion', ['--all', '--specs-file', specs_file]).assertResult(
            self, stdout="app1=3.x.x@any[.]\r\napp1=2.x.x@any[.]\r\napp1=2.x.x@any[.]\r\n")

