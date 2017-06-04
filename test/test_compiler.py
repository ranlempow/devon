# noqa: V, D
import os
import sys
import unittest

from .utils import ScriptTestCase, Removed
from scripts.shellexec import ShellCompiled  # noqa: U

class Test(ScriptTestCase):
    target = 'compiler.cmd'

    @classmethod
    def setUpClass(cls):
        cls.setup_main_target(cls.target)
        testdir = cls.subdir('')
        cls.target_path = os.path.join(testdir, 'compiler.cmd')
        with open(cls.target_path, 'w') as fp:
            fp.write("""


@rem ==== Include ====

#include("test_include.cmd")

::: function IncludeData()
    #include(RET, "test_include_data.txt")
    return %RET%
::: endfunc

::: function InlineData()
    call :get_inline
    return %RET%
::: endfunc

:get_inline
::: inline(RET)
data
::: endinline
@goto :eof




@rem ==== Functions ====

::: function NoArg()
    set RET=OK
    return %RET%
::: endfunc

::: function OneArg(a)
    set RET=%a%
    return %RET%
::: endfunc

::: function RequireArg(a, b=)
    set RET=%b%
    return %RET%
::: endfunc

::: function OptionalArg(a, b=?)
    set RET=%b%
    return %RET%
::: endfunc

::: function SwitchArg(a, b=N)
    set RET=%b%
    return %RET%
::: endfunc

::: function DefaultArg(a, b=DEF)
    set RET=%b%
    return %RET%
::: endfunc

::: function VarArgsQuote(a, args=...)
    set RET=%args%
    return %RET%
::: endfunc

::: function VarArgsOrigin(a, args=....)
    set RET=%args%
    return %RET%
::: endfunc

::: function VarArgsNoQuote(a, args=.....)
    set RET=%args%
    return %RET%
::: endfunc

::: function VarArgsWithOption(a, b=, args=...)

::: endfunc

::: function VarArgsWithDefault(a, b=DEF, args=...)

::: endfunc






@rem ==== Returns ====

::: function MultiReturn()
    set RET1=OK
    set RET2=OK
    return %RET1%, %RET2%
::: endfunc

::: function MultiLineReturn()
    set RET1=OK
    set RET2=OK
    return %RET1%, ^\\n^
           %RET2%
::: endfunc

::: function InblockReturn_inner() extensions delayedexpansion
    FOR /L %%G IN (1,1,2) DO (
        set RET=%%G
        return !RET!
    )
::: endfunc



@rem ==== Error & Call ====

::: function ErrorFunc()
    error("errormsg")
::: endfunc


::: function CatchError()
    pcall :ErrorFunc
    set RET=%EMSG%
    set EMSG=
    return %RET%
::: endfunc

::: function PassErrorByCall()
    set RET=Yes
    call :ErrorFunc
    set RET=No
    return %RET%
::: endfunc

::: function PassErrorByNCall()
    set RET=Yes
    ncall :ErrorFunc
    set RET=No
    return %RET%
::: endfunc


@rem TODO: error var
@rem TODO: error print
@rem TODO: error callstack



""")
        target2_path = os.path.join(cls.target_path, '..', 'test_include.cmd')
        with open(target2_path, 'w') as fp:
            fp.write("""

::: function Outter()
    set RET=OK
    return %RET%
::: endfunc

""")
        target3_path = os.path.join(cls.target_path, '..', 'test_include_data.txt')
        with open(target3_path, 'w') as fp:
            fp.write("data")

        script = ShellCompiled(cls.target_path, testdir=testdir)
        cls.testdir, cls.script = testdir, script

    def test_NoArg(self):
        self.script.call('NoArg').assertResult(
            self, stdout="", added={'RET': 'OK'})

    def test_NoArg_but_given(self):
        self.script.call('NoArg', ['x']).assertResult(self, stderr=None, added={}, ret=1)

    def test_OneArg(self):
        self.script.call('OneArg', ['x']).assertResult(
            self, stdout="", added={'RET': 'x'})

    def test_OneArg_but_none(self):
        self.script.call('OneArg').assertResult(self, stderr=None, added={}, ret=1)

    def test_OneArg_but_two(self):
        self.script.call('OneArg', ['x', 'y']).assertResult(self, stderr=None, added={}, ret=1)

    def test_RequireArg(self):
        self.script.call('RequireArg', ['x', 'y']).assertResult(
            self, stdout="", added={'RET': 'y'})

    def test_RequireArg_not_given(self):
        self.script.call('RequireArg', ['x']).assertResult(
            self, stdout="", added={})

    def test_OptionalArg(self):
        self.script.call('OptionalArg', ['x', '--b', 'y']).assertResult(
            self, stdout="", added={'RET': 'y'})

    def test_OptionalArg_not_given(self):
        self.script.call('OptionalArg', ['x']).assertResult(
            self, stdout="", added={})


    def test_SwitchArg(self):
        self.script.call('SwitchArg', ['x']).assertResult(
            self, stdout="", added={})
        self.script.call('SwitchArg', ['x', '--b']).assertResult(
            self, stdout="", added={'RET': '1'})

    def test_SwitchArg_but_assign(self):
        self.script.call('SwitchArg', ['x', '--b', 'y']).assertResult(
            self, stderr=None, added={}, ret=1)

    def test_DefaultArg(self):
        self.script.call('DefaultArg', ['x']).assertResult(
            self, stdout="", added={'RET': 'DEF'})
        self.script.call('DefaultArg', ['x', '--b', 'ABC']).assertResult(
            self, stdout="", added={'RET': 'ABC'})

    def test_VarArgsQuote(self):
        self.script.call('VarArgsQuote', ['x', '--b', 'ABC', '"quoted x"']).assertResult(
            self, stdout="", added={'RET': '"--b" "ABC" "quoted x"'})

    # def test_VarArgsOrigin(self):
    #     self.script.call('VarArgsOrigin', ['x', '--b', 'ABC', '"quoted x"']).assertResult(
    #         self, stdout="", added={'RET': ' --b ABC "quoted x"'})

    def test_VarArgsNoQuote(self):
        self.script.call('VarArgsNoQuote', ['x', '--b', 'ABC', '"quoted x"']).assertResult(
            self, stdout="", added={'RET': '--b ABC quoted x'})

    def test_MultiReturn(self):
        self.script.call('MultiReturn').assertResult(
            self, stdout="", added={'RET1': 'OK', 'RET2': 'OK'})

    def test_MultiLineReturn(self):
        self.script.call('MultiLineReturn').assertResult(
            self, stdout="", added={'RET1': 'OK', 'RET2': 'OK'})

    # def test_InblockReturn(self):
    #     self.script.call('InblockReturn').assertResult(
    #         self, stdout="", added={'RET': '1'})

    def test_IncludeCmd(self):
        self.script.call('Outter').assertResult(
            self, stdout="", added={'RET': 'OK'})

    def test_IncludeData(self):
        self.script.call('IncludeData').assertResult(
            self, stdout="", added={'RET': 'data'})

    def test_InlineData(self):
        self.script.call('InlineData').assertResult(
            self, stdout="", added={'RET': 'data'})

    def test_ErrorFunc(self):
        self.script.call('ErrorFunc').assertResult(self, stderr=None, added={}, ret=1)

    def test_CatchError(self):
        self.script.call('CatchError').assertResult(
            self, stdout="", added={'RET': 'errormsg'})

    def test_PassErrorByCall(self):
        self.script.call('PassErrorByCall').assertResult(
            self, stderr=None, added={}, ret=1)

    def test_PassErrorByNormalCall(self):
        self.script.call('PassErrorByNCall').assertResult(
            self, stderr=None, added={}, ret=1)
