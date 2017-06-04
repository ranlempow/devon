import os
import sys
import shutil
import atexit
import unittest
from testfixtures import TempDirectory
from testfixtures.rmtree import rmtree

BRICKV_ROOT = os.path.abspath(os.path.join(__file__, '..', '..'))
SRC_DIR = 'devon'
TEST_DIR = 'var'
sys.path.insert(0, BRICKV_ROOT)

from scripts.shellexec import ShellCompiled, ScriptExecution, Parser  # noqa: U
Removed = ''


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



class CaseBox(TempDirectory):
    def __init__(self, *args, **kwargs):
        self.parent = kwargs.pop('parent', None)
        self.env = kwargs.pop('env', os.environ).copy()
        self.origin_env = self.env.copy()
        self.origin_cwd = os.getcwd()
        self.rmtree = rmtree
        TempDirectory.__init__(self, *args, **kwargs)


    def create(self):
        """
        inherit
        """


        if self.path:
            if os.path.exists(self.get_finish_path()):
                self.rmtree(self.get_finish_path())
            if all(inst.path != self.path
                   for inst in self.instances):
                # this instance is the first created of given path
                self.rmtree(self.path)

        os.makedirs(self.path, exist_ok=True)
        os.chdir(self.path)
        # below is copy from testfixtures source code
        self.instances.add(self)
        if not self.__class__.atexit_setup:
            atexit.register(self.atexit)
            self.__class__.atexit_setup = True
        return self

    def cleanup(self):
        super().cleanup()
        os.chdir(self.origin_cwd)
        if all(inst.path != self.path
               for inst in self.instances):
            # this instance is the last cleanup of given path
            os.rename(self.path, self.get_finish_path())

    def get_finish_path(self):
        return os.path.join(
                    os.path.dirname(self.path),
                    '_finish_' + os.path.basename(self.path))

    def subcase(self, path=None, push=False):
        _path = self.getpath(path or ())
        box = CaseBox(path=_path, parent=self, env=self.env)
        if push and self.get_ancient_attr('script_source', None):
            box._compile(self.get_ancient_attr('script_source'))
        return box

    def _compile(self, source, debug=False):
        source_path = os.path.join(BRICKV_ROOT, SRC_DIR, source)
        self.script_source = source
        self.script_path = self.getpath(os.path.basename(source_path))
        self.script_body = Parser.parsefile(source_path, debug=debug)
        with open(self.script_path, 'w', encoding='utf-8') as fp:
            fp.write(self.script_body)

    def setEnv(self, **kwargs):
        for k, v in kwargs.items():
            if v == '' and k in self.env:
                del self.env[k]
            else:
                self.env[k] = v

    def clearAllEnv(self):
        self.env = self.origin_env.copy()

    def call(self, label, args=[], env=None):
        compiled_path = self.get_ancient_attr('script_path')
        subroutine_path = compiled_path[:-4] + label + '.cmd'
        with open(subroutine_path, 'w', encoding='utf-8') as fp:
            fp.write('@set TEST_SHELL=1\n')
            fp.write('@echo off\n')
            fp.write('@call :{} %*\n'.format(label))
            fp.write('@if not "%EMSG%" == "" @call :_Error\n')
            fp.write('@goto :eof\n')
            fp.write(self.get_ancient_attr('script_body'))
        shexe = ScriptExecution(subroutine_path[:-4], args, env or self.env)
        shexe.case = self.get_ancient_attr('case')
        return shexe

    def execute(self, script_path=None, args=[], env=None):
        script_path = script_path or self.get_ancient_attr('script_path')
        # return ScriptExecution(script_path[:-4], args, env or self.env)
        shexe = ScriptExecution(script_path[:-4], args, env or self.env)
        shexe.case = self.get_ancient_attr('case')
        return shexe

    def get_ancient_attr(self, attr, default='__no_default__'):
        if getattr(self, attr, None):
            return getattr(self, attr)
        elif self.parent:
            return self.parent.get_ancient_attr(attr)
        else:
            if default != '__no_default__':
                return default
            else:
                raise Exception('{} not defined'.format(attr))

    def _makeslash(self, path, endslash):
        if endslash:
            if not path.endswith(os.sep):
                return path + os.sep
        elif path.endswith(os.sep):
            return path[:-1]
        return path

    def getpath(self, path=None, endslash=False):
        _path = super().getpath(path or ())
        return self._makeslash(_path, endslash)


    def absjoin(self, base, name, endslash=False):
        # make things platform independent
        if isinstance(name, (str,bytes)):
            name = name.split('/')
        relative = os.sep.join(name).rstrip(os.sep)
        _path = os.path.join(os.path.expandvars(os.path.expanduser(base)), relative)
        return self._makeslash(_path, endslash)


class ScriptTestCase(unittest.TestCase):
    maxDiff = None

    # change PROMPT to default value is needed for test in devon environ
    os.environ['PROMPT'] = '$P$G'
    for attr in ('PRJ_BIN,PRJ_CONF,PRJ_LOG,PRJ_ROOT,PRJ_TMP,PRJ_VAR,'
                 'TITLE,DEVON_CONFIG_PATH,BRICKV_LOCAL_DIR,BRICKV_GLOBAL_DIR').split(','):
        if attr in os.environ:
            del os.environ[attr]

    @classmethod
    def setup_main_target(cls, target):
        target_path = os.path.join(BRICKV_ROOT, SRC_DIR, target)
        main_testdir = os.path.join(BRICKV_ROOT, TEST_DIR, '.'.join(target.rsplit('.', 1)[:-1]))
        cls._box = CaseBox(path=main_testdir)
        cls._box._compile(target_path)

    @classmethod
    def setUpClass(cls):
        if hasattr(cls, 'target'):
            cls.setup_main_target(cls.target)

    @classmethod
    def tearDownClass(cls):
        if hasattr(cls, '_box'):
            cls._box.cleanup()

    def setUp(self):
        self.box = self._box.subcase()
        self.box.case = self

    def tearDown(self):
        self.box.cleanup()

class ScriptTestCase2(unittest.TestCase):
    maxDiff = None
    # target = None

    # change PROMPT to default value is needed for test in devon environ
    os.environ['PROMPT'] = '$P$G'
    for attr in ('PRJ_BIN,PRJ_CONF,PRJ_LOG,PRJ_ROOT,PRJ_TMP,PRJ_VAR,'
                 'TITLE,DEVON_CONFIG_PATH,BRICKV_LOCAL_DIR,BRICKV_GLOBAL_DIR').split(','):
        if attr in os.environ:
            del os.environ[attr]

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

