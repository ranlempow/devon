# noqa: V, D

import os
import sys
import subprocess

from .cmdcompiler import Parser  # noqa: U


class CaseInsensitiveDict(dict):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.case_mapping = dict((k.upper(), k)for k in self.keys())

    def __setitem__(self, key, value):
        self.case_mapping[key.upper()] = key
        super().__setitem__(key, value)

    def __delitem__(self, key):
        del self.case_mapping[key.upper()]
        super().__delitem__(key)

    def __getitem__(self, key):
        return super().__getitem__(self.case_mapping[key.upper()])


class DictDiffer(object):
    """
    Calculate the difference between two dictionaries as:
    (1) items added
    (2) items removed
    (3) keys same in both but changed values
    (4) keys same in both and unchanged values
    """
    def __init__(self, current_dict, past_dict):
        self.current_dict, self.past_dict = current_dict, past_dict
        self.set_current = set(k.upper() for k in current_dict.keys())
        self.set_past = set(k.upper() for k in past_dict.keys())
        self.intersect = self.set_current.intersection(self.set_past)

    def _wrapper_of_keys(self, keys, _dict):
        # if hasattr(_dict, 'case_mapping'):
        #     f = lambda k: (_dict.case_mapping[k.upper()], _dict[k])
        # else:
        f = lambda k: (k, _dict[k])
        return dict(f(k) for k in keys)

    @property
    def added_key(self):
        return self.set_current - self.intersect

    @property
    def added(self):
        return self._wrapper_of_keys(self.added_key, self.current_dict)

    @property
    def removed_key(self):
        return self.set_past - self.intersect

    @property
    def removed(self):
        return self._wrapper_of_keys(self.removed_key, self.past_dict)

    @property
    def changed_key(self):
        return set(o for o in self.intersect if self.past_dict[o] != self.current_dict[o])

    @property
    def changed(self):
        return self._wrapper_of_keys(self.changed_key, self.current_dict)

    @property
    def unchanged_key(self):
        return set(o for o in self.intersect if self.past_dict[o] == self.current_dict[o])

    @property
    def unchanged(self):
        return self._wrapper_of_keys(self.unchanged_key, self.current_dict)


class Execution:
    # create a tag so we can tell in the output when the proc is done
    tag = b'### Done running command ###'

    def __init__(self, cmd, env=None):
        self.cmd = cmd
        self.env = env if env is not None else os.environ.copy()
        if self.minimal_env is not None:
            for k in self.minimal_env.keys():
                if k not in self.env:
                    self.env[k] = self.minimal_env[k]

    def run(self):
        # remember environment before running process
        env_before = CaseInsensitiveDict(self.env)
        # launch the process
        proc = subprocess.Popen(self.cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=self.env)

        # parse the output sent to stdout
        stdout_text = b''
        try:
            line = b''
            while(self.tag not in line):
                stdout_text += line
                line = next(proc.stdout)
        except StopIteration:
            pass

        # define a way to handle each KEY=VALUE line
        def to_str(byte_list):
            return tuple(map(lambda i: self.decode(i), byte_list))

        handle_line = lambda l: to_str(l.rstrip().split(b'=', 1))
        # parse key/values into pairs
        pairs = map(handle_line, proc.stdout)
        # make sure the pairs are valid
        valid_pairs = filter(self.validate_pair, pairs)
        # construct a dictionary of the pairs
        env_after = CaseInsensitiveDict(valid_pairs)

        stderr_text = proc.stderr.read()
        self.stderr = self.decode(stderr_text)
        self.stdout = self.decode(stdout_text)

        # let the process finish
        proc.communicate()
        if 'TEST_SHELL' in env_after:
            del env_after['TEST_SHELL']

        self.returncode = proc.returncode
        if '_errorlevel' in env_after:
            self.returncode = 1
            del env_after['_errorlevel']

        self.before = env_before
        self.after = env_after
        self.diff = DictDiffer(env_after, env_before)


        return self

    def decode(self, buff):
        try:
            string = buff.decode(sys.stdout.encoding)
        except UnicodeDecodeError:
            string = buff.decode('big5')
        return string

    @staticmethod
    def validate_pair(ob):
        try:
            if not (len(ob) == 2):
                print("Unexpected result:", ob, file=sys.stderr)
                raise ValueError
        except:
            return False
        return True


    def __str__(self):
        txt = '''return={}
cmd={}

[stdout]
{}

[stderr]
{}

[added]
{}

[changed]
{}

[removed]
{}
'''.format(
            self.returncode,
            self.cmd,
            self.stdout,
            self.stderr,
            '\n'.join('{}={}'.format(k, self.diff.added[k]) for k in sorted(self.diff.added.keys())),
            '\n'.join('{}={}'.format(k, self.diff.changed[k]) for k in sorted(self.diff.changed.keys())),
            str(self.diff.removed.keys()),
        )
        return txt

    def modifyEnv(self, **kwargs):
        for k, v in kwargs.items():
            if v == '' and k in self.env:
                del self.env[k]
            else:
                self.env[k] = v

    def assertSuccess(self, stdout='', stderr=''):
        return self.assertResult(None, ret=0, stdout=stdout, stderr=stderr,
                                 added=None, changed=None)

    def assertFailure(self, stdout='', stderr=''):
        return self.assertResult(None, ret=1, stdout=stdout, stderr=stderr,
                                 added=None, changed=None)

    def assertEnv(self, **kwargs):
        return self.assertResult(None, ret=None, stdout=None, stderr=None,
                                 added=None, changed=None, env=kwargs)

    def assertResult(self, case=None, *, ret=0, stdout='', stderr='',
                     added={}, changed={}, removed=None, env=None):
        if not hasattr(self, 'diff'):
            self.run()
        case = case or getattr(self, 'case')
        try:
            if ret is not None:
                case.assertEqual(ret, self.returncode, 'return code not match')
            if stdout is not None:
                if isinstance(stdout, list):
                    stdout = os.linesep.join(stdout + [''])
                case.assertEqual(stdout, self.stdout, 'stdout not match')
            if stderr is not None:
                if isinstance(stderr, list):
                    stderr = os.linesep.join(stderr + [''])
                case.assertEqual(stderr, self.stderr, 'stderr not match')
            if added is not None:
                case.assertEqual(added, self.diff.added, 'environ added not match')
            if changed is not None:
                case.assertEqual(changed, self.diff.changed, 'environ changed not match')
            if removed is not None:
                case.assertEqual(removed, self.diff.removed, 'environ removed not match')
            if env is not None:
                env_dict = {}
                env_dict.update(self.diff.added)
                env_dict.update(self.diff.changed)
                env_dict.update(dict((k, '') for k in self.diff.removed_key))
                env_dict.update(dict((k, None) for k, v in env.items() if v is None))
                case.assertEqual(env, env_dict, 'environ not match')

        except AssertionError as e:
            print(self.stderr)
            e.__traceback__ = e.__traceback__
            raise e

        return self

    @classmethod
    def get_cmd_from_cmds_list(cls, *cmds_list):
        """
        Take a command (either a single command or list of arguments)
        and return the environment created after running that command.
        Note that if the command must be a batch file or .cmd file, or the
        changes to the environment will not be captured.

        If env is supplied, it is used as the initial environment passed
        to the child process.
        """

        # construct the command that will alter the environment

        cmdstr_list = []
        for cmds in cmds_list:
            if not isinstance(cmds, (list, tuple)):
                cmds = [cmds]
            if cmds[0] and cmds[0][0] == '@':
                cmds[1:] = map(lambda x: '"{0}"'.format(x.strip('"')), cmds[1:])
            else:
                cmds = map(lambda x: '"{0}"'.format(x.strip('"')), cmds)

            cmdstr = ' '.join(cmds)
            cmdstr_list.append(cmdstr)

        cmds_list = ('({0} || @set _errorlevel="1")'.format(' & '.join(cmdstr_list)),
                     '@echo ' + cls.tag.decode('utf-8'),
                     '@set',
                     )
        cmdstr_list = cmds_list

        # construct a cmd.exe command to do accomplish this
        final_cmd = ' & '.join(cmdstr_list)
        cmd = 'cmd.exe /s /c {}'.format(final_cmd)
        return cmd

    minimal_env = None

    @classmethod
    def get_minimal_env(cls):
        r = cls(cls.get_cmd_from_cmds_list(), env={}).run()
        return r.after

Execution.minimal_env = Execution.get_minimal_env()


class ScriptExecution(Execution):
    def __init__(self, script, args=[], env=None):
        self.script = script
        cmd = Execution.get_cmd_from_cmds_list(
            ['@call {}.cmd'.format(script.replace('/', '\\'))] + args)
        super().__init__(cmd, env=env)


class ShellCompiled():
    def __init__(self, script, testdir='', debug=False):
        self.testdir = testdir
        self.compiled_path = os.path.join(self.testdir, os.path.basename(script))
        self.script_body = Parser.parsefile(script, debug=debug)
        with open(self.compiled_path, 'w', encoding='utf-8') as fp:
            fp.write(self.script_body)

    def execute(self, args=[], cwd=None, env=None):
        os.chdir(cwd or self.testdir)
        return ScriptExecution(self.compiled_path[:-4], args, env).run()

    def create_for_call(self, label, args=[], cwd=None, env=None):
        os.chdir(cwd or self.testdir)
        subroutine_path = self.compiled_path[:-4] + label + '.cmd'
        with open(subroutine_path, 'w', encoding='utf-8') as fp:
            fp.write('@set TEST_SHELL=1\n')
            fp.write('@echo off\n')
            fp.write('@call :{} %*\n'.format(label))
            fp.write('@if not "%EMSG%" == "" @call :_Error\n')
            fp.write('@goto :eof\n')
            fp.write(self.script_body)
        return ScriptExecution(subroutine_path[:-4], args, env)

    def call(self, label, args=[], cwd=None, env=None):
        return self.create_for_call(label, args, cwd, env).run()


def _test():
    print(ScriptExecution('base/get-args', ['haha', '"haha "']).run())
    print(ScriptExecution.minimal_env)

