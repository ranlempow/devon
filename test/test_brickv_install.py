# noqa: V, D
import os
import unittest

from .utils import ScriptTestCase, Removed
from scripts.shellexec import ShellCompiled  # noqa: U


class Test(ScriptTestCase):
    target = 'brickv_CMD_install2.cmd'
    @classmethod
    def setUpClass(cls):
        cls.setup_main_target(cls.target)
        cls.testdir, cls.script = cls.subscript()
        cls.script.script_body += """
:test_init
goto :eof
:test_versions
echo.test=1.2.3> "%VERSION_SPCES_FILE%"
        """

    def test_BrickvInstall_init(self):
        label = 'brickv_install_init'
        env = os.environ.copy()
        env.update({"spec": "test=x",
                    "SCRIPT_SOURCE": self.script.compiled_path[:-4] + label + '.cmd',
                   })

        # self.script.call(label, [], env=env).assertResult(
        #     self, stdout='', added={
        #         'BRICKV_GLOBAL_DIR': 'C:\\Users\\ran\\AppData\\Local\\Programs',
        #         'BRICKV_LOCAL_DIR': 'C:\\Users\\ran\\Desktop\\brickv\\var\\brickv_prepare',
        #         'LOG_LEVEL': '3',
        #         'REQUEST_SPEC': '=x',
        #     })

    def test_BrickvInstall_versions(self):
        label = 'brickv_install_versions'
        env = os.environ.copy()
        env.update({"APPNAME": "test",
                    "REQUEST_SPEC": "test=x",
                    "SCRIPT_SOURCE": self.script.compiled_path[:-4] + label + '.cmd',
                    "TEMP": os.path.dirname(self.script.compiled_path),
                   })

        self.script.call(label, [], env=env).assertResult(
            self, stdout='', added={
                'MATCH_APP': 'test',
                'MATCH_ARCH': 'any',
                'MATCH_MAJOR': '1',
                'MATCH_MINOR': '2',
                'MATCH_NAME': 'none',
                'MATCH_PATCH': '3',
                'MATCH_PATCHES': '.',
                'MATCH_VER': '1.2.3',
                'VERSION_SOURCE_FILE': 'C:\\Users\\ran\\Desktop\\brickv\\var\\brickv_CMD_install2\\source-test.ver.txt',
                'VERSION_SPCES_FILE': 'C:\\Users\\ran\\Desktop\\brickv\\var\\brickv_CMD_install2\\spces-test.ver.txt',
            })

    def test_BrickvInstall_versions(self):
        label = 'brickv_install_predownload'
        # env = os.environ.copy()
        # env.update({"APPNAME": "test",
        #             "REQUEST_SPEC": "test=x",
        #             "SCRIPT_SOURCE": self.script.compiled_path[:-4] + label + '.cmd',
        #             "TEMP": os.path.dirname(self.script.compiled_path),
        #            })

        # self.script.call(label, [], env=env).assertResult(
        #     self,)

