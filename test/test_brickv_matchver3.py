# noqa: V, D
import os
import unittest

from .utils import ScriptTestCase, Removed


class Test(ScriptTestCase):
    target = 'semver3.cmd'

    def test_MatchVersion_complete_format(self):
        self.script.call('MatchVersion', ['app1']).assertResult(
            self, stdout="none:app1=x.x.x_any[.]\r\n")

    def test_MatchVersion_cmd_format(self):
        self.script.call('MatchVersion', ['--output-format', 'cmd', 'app1']).assertResult(
            self, stdout='none app1 x x x any "." "" ""\r\n')

    def test_MatchVersion_env_simple(self):
        self.script.call('MatchVersion', ['--output-format', 'env', 'app1']).assertResult(
            self, stdout="", added={
                'MATCH_NAME': 'none',
                'MATCH_APP': 'app1',
                'MATCH_ARCH': 'any',
                'MATCH_MAJOR': 'x',
                'MATCH_MINOR': 'x',
                'MATCH_PATCH': 'x',
                'MATCH_PATCHES': '.',
                'MATCH_VER': 'x'})

    def test_MatchVersion_env_easy(self):
        self.script.call('MatchVersion', ['--output-format', 'env', 'name:host-venv=3.2']).assertResult(
            self, stdout="", added={
                'MATCH_NAME': 'name',
                'MATCH_APP': 'host-venv',
                'MATCH_ARCH': 'any',
                'MATCH_MAJOR': '3',
                'MATCH_MINOR': '2',
                'MATCH_PATCH': 'x',
                'MATCH_PATCHES': '.',
                'MATCH_VER': '3.2'})

    def test_MatchVersion_env_hard(self):
        self.script.call('MatchVersion', ['--output-format', 'env', 'name:host-venv=3.2_x64[p1,p2]@local@no-select']).assertResult(
            self, stdout="", added={
                'MATCH_NAME': 'name',
                'MATCH_APP': 'host-venv',
                'MATCH_ARCH': 'x64',
                'MATCH_MAJOR': '3',
                'MATCH_MINOR': '2',
                'MATCH_PATCH': 'x',
                'MATCH_PATCHES': 'p1,p2',
                'MATCH_OPTIONS': 'local,no-select',
                'MATCH_VER': '3.2'})

    def test_MatchVersion_carry(self):
        self.script.call('MatchVersion', ['app1$carrydata']).assertResult(
            self, stdout="none:app1=x.x.x_any[.]$carrydata\r\n")
        self.script.call('MatchVersion', ['--output-format', 'cmd', 'app1$carrydata']).assertResult(
            self, stdout='none app1 x x x any "." "" "carrydata"\r\n')
        self.script.call('MatchVersion', ['--output-format', 'env', 'app1$carrydata']).assertResult(
            self, stdout="", added={
                'MATCH_NAME': 'none',
                'MATCH_APP': 'app1',
                'MATCH_ARCH': 'any',
                'MATCH_MAJOR': 'x',
                'MATCH_MINOR': 'x',
                'MATCH_PATCH': 'x',
                'MATCH_PATCHES': '.',
                'MATCH_VER': 'x',
                'MATCH_CARRY': 'carrydata'})

    def test_MatchVersion_all(self):
        self.script.call('MatchVersion', ['--all', 'app1=2', 'app1=3', 'app1=2']).assertResult(
            self, stdout=("none:app1=3.x.x_any[.]\r\n"
                          "none:app1=2.x.x_any[.]\r\n"
                          "none:app1=2.x.x_any[.]\r\n"))

        self.script.call('MatchVersion', ['--all', 'app1=1.2.3', 'app1=3.2.1', 'app2=3.2.1']).assertResult(
            self, stdout=("none:app2=3.2.1_any[.]\r\n"
                          "none:app1=3.2.1_any[.]\r\n"
                          "none:app1=1.2.3_any[.]\r\n"))

    def test_MatchVersion_match(self):
        self.script.call('MatchVersion', ['--spec-match', 'app1', 'app1', 'app2']).assertResult(
            self, stdout="none:app1=x.x.x_any[.]\r\n")
        self.script.call('MatchVersion', ['--spec-match', 'app1=2', 'app1=3', 'app1=2']).assertResult(
            self, stdout="none:app1=2.x.x_any[.]\r\n")
        self.script.call('MatchVersion', ['--spec-match', 'app1=2', 'app1=3.1', 'app1=2.3']).assertResult(
            self, stdout="none:app1=2.3.x_any[.]\r\n")
        self.script.call('MatchVersion', ['--spec-match', 'app1_x64', 'app1=3_x86', 'app1=2_x64']).assertResult(
            self, stdout="none:app1=2.x.x_x64[.]\r\n")

    def test_MatchVersion_specs_file(self):
        specs_file = os.path.join(self.testdir, 'specs_file.txt')
        with open(specs_file, 'w') as fp:
            fp.write('app1=2.x.x_any[.]\r\napp1=3.x.x_any[.]\r\napp1=2.x.x_any[.]\r\n')
        self.script.call('MatchVersion', ['--all', '--specs-file', specs_file]).assertResult(
            self, stdout=("none:app1=3.x.x_any[.]\r\n"
                          "none:app1=2.x.x_any[.]\r\n"
                          "none:app1=2.x.x_any[.]\r\n"))

