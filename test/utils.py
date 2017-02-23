import os
import sys
import shutil
import unittest

BRICKV_ROOT = os.path.abspath(os.path.join(__file__, '..', '..'))
SRC_DIR = 'devon'
TEST_DIR = 'var'
sys.path.insert(0, BRICKV_ROOT)

from scripts.shellexec import ShellCompiled  # noqa: U

def onerror(func, path, exc_info):
    """
    Error handler for ``shutil.rmtree``.

    If the error is due to an access error (read only file)
    it attempts to add write permission and then retries.

    If the error is for another reason it re-raises the error.

    Usage : ``shutil.rmtree(path, onerror=onerror)``
    """
    import stat
    if not os.path.exists(path):
        pass
    elif not os.access(path, os.W_OK):
        # Is the error an access error ?
        os.chmod(path, stat.S_IWUSR)
        func(path)
    else:
        raise

class ScriptTestCase(unittest.TestCase):
    maxDiff = None
    # target = None

    @classmethod
    def setup_main_target(cls, target):
        cls.target = target
        cls.target_path = os.path.join(BRICKV_ROOT, SRC_DIR, target)
        os.makedirs(os.path.join(BRICKV_ROOT, TEST_DIR), exist_ok=True)
        cls.main_testdir = os.path.join(BRICKV_ROOT, TEST_DIR, '.'.join(target.rsplit('.', 1)[:-1]))


    @classmethod
    def setUpClass(cls):
        cls.setup_main_target(cls.target)
        cls.testdir, cls.script = cls.subscript()

    @classmethod
    def subdir(cls, *sub_path_piece):
        testdir = os.path.join(cls.main_testdir, *sub_path_piece)
        testdir = os.path.abspath(testdir)
        shutil.rmtree(testdir, onerror=onerror)
        os.makedirs(testdir, exist_ok=True)
        return testdir

    @classmethod
    def subscript(cls, subdir=''):
        testdir = cls.subdir(subdir)
        script = ShellCompiled(cls.target_path, testdir=testdir)
        return testdir, script

