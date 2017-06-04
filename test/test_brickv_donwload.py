# noqa: V, D
import os
import unittest

from .utils import ScriptTestCase, Removed


class Test(ScriptTestCase):
    target = 'brickv_download.cmd'

    def test_BrickvDonwload_download(self):
        url = 'https://raw.githubusercontent.com/ranlempow/fonts/master/README.md'
        output= os.path.join(self.testdir, 'README.md')
        self.script.call('BrickvDownload', [url, output]).assertResult(
            self, stdout='brickv fetch ' + url + os.linesep)
        self.assertEqual(open(output).read(), '# fonts')

    def test_BrickvDonwload_faild1(self):
        url = 'https://raw.githubusercontent.com/ranlempow/fonts/master/XXX.md'
        output= os.path.join(self.testdir, 'XXX.md')
        result = self.script.call('BrickvDownload', [url, output])
        result.assertResult(
            self, stdout=None, stderr=None, ret=1)
        self.assertTrue('[download] Unable connect to' in result.stderr)
