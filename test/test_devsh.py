# noqa: V, D
import os
import unittest

from .utils import ScriptTestCase, Removed


class Test(ScriptTestCase):
    target = 'dev-sh.cmd'

    def test_AddPathUnique(self):
        self.box.call('AddPathUnique', ['x']
               ).assertSuccess().assertEnv(PATH='x;' + self.box.env['PATH'])
        if os.name == 'nt':
            self.box.call('AddPathUnique', ['C:\\Windows']).assertSuccess()

    def test_active(self):
        # SCRIPT_SOURCE
        with self.box.subcase('active_test', push=True) as box:
            box.setEnv(SCRIPT_SOURCE=box.get_ancient_attr('script_path'))
            exe = box.call('ActiveDevShell', []).run()
            exe.assertSuccess(stdout=None)

            # testdir, script = self.subscript('active_test')
            # exe = script.create_for_call('ActiveDevShell')
            # exe.env.update({'SCRIPT_SOURCE': exe.script + '.cmd'})
            # exe.run()
            # # self.assertTrue('DEVON_CONFIG_PATH' in exe.diff.added)
            # # self.assertEquel(exe.diff.added['DEVON_CONFIG_PATH'], exe.script + '.cmd')
            # print(exe.stdout)
            # print(exe.after)

            self.assertTrue('PRJ_BIN' in exe.diff.added)
            self.assertTrue('PRJ_CONF' in exe.diff.added)
            self.assertTrue('PRJ_LOG' in exe.diff.added)
            self.assertTrue('PRJ_TMP' in exe.diff.added)
            self.assertTrue('PRJ_VAR' in exe.diff.added)

            self.assertTrue('PRJ_ROOT' in exe.diff.added)
            self.assertEqual(exe.diff.added['PRJ_ROOT'], testdir)
            self.assertTrue('TITLE' in exe.diff.added)
            self.assertEqual(exe.diff.added['TITLE'], 'active_test')


# class Test(ScriptTestCase):
#     target = 'dev-sh.cmd'

#     def test_AddPathUnique(self):
#         self.script.call('AddPathUnique', ['x']).assertResult(
#             self, stdout="", changed={'PATH':'x;' + os.environ['PATH']})
#         self.script.call('AddPathUnique', ['C:\\Windows']).assertResult(
#             self, stdout="")

#     def test_active(self):
#         # SCRIPT_SOURCE
#         testdir, script = self.subscript('active_test')
#         exe = script.create_for_call('ActiveDevShell')
#         exe.env.update({'SCRIPT_SOURCE': exe.script + '.cmd'})
#         exe.run()
#         # self.assertTrue('DEVON_CONFIG_PATH' in exe.diff.added)
#         # self.assertEquel(exe.diff.added['DEVON_CONFIG_PATH'], exe.script + '.cmd')
#         print(exe.stdout)
#         print(exe.after)

#         self.assertTrue('PRJ_BIN' in exe.diff.added)
#         self.assertTrue('PRJ_CONF' in exe.diff.added)
#         self.assertTrue('PRJ_LOG' in exe.diff.added)
#         self.assertTrue('PRJ_TMP' in exe.diff.added)
#         self.assertTrue('PRJ_VAR' in exe.diff.added)

#         self.assertTrue('PRJ_ROOT' in exe.diff.added)
#         self.assertEqual(exe.diff.added['PRJ_ROOT'], testdir)
#         self.assertTrue('TITLE' in exe.diff.added)
#         self.assertEqual(exe.diff.added['TITLE'], 'active_test')



