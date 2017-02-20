# noqa: V, D
"""
目前支援的語法

1. function
    ::: function NAME(...) ...
    ::: endfunc
    define a function

2. inline
    ::: inline(VAR)
    ::: endinline
    put content in a variable

3. include
    `#include("PATH")`
    include a file in that position.
    a file already included will not be include twice.

    `#include(VAR, "PATH")`
    put a file content in a variable
    note: please notice the scope of that variable

5. return
    `return {VAR1}, {VAR2}, ...`
    exit function and return values to upper scope
    `{VAR}` can be `%VAR%`, `!VAR!` and `strings`

6. error and debug
    `error("MESSAGE")`
    throw a error cause immediately exit function

    `debug("MESSAGE")`
    print message when debug mode or under testing.

7. call
    Function Call
    `ncall :{FunctionName} {Args...}`

    Protected Function Call
    `pcall :{FunctionName} {Args...}`

    call function with commandline-like paramaters,
    if error raises then exit functions until encounter protected call.

8. line merge
    when line ends with `^\n^`
"""

import re
import os





def gen_return(parser, line, match):
    output = []
    values = match.group(1)
    values = values.lstrip()
    rets = [p.strip() for p in values.split(',')]
    rets += ['%ERROR_MSG%', '%ERROR_SOURCE%', '%ERROR_BLOCK%', '%ERROR_LINENO%', '%ERROR_CALLSTACK%']
    ret_output = []
    for ret in rets:
        if ret == '':
            continue
        accessor = ''
        if ret.startswith('%') and ret.endswith('%'):
            accessor = '%'
        if ret.startswith('!') and ret.endswith('!'):
            accessor = '!'
        ret = ret.strip(accessor)
        if accessor == '':
            accessor = '%'
        ret_output.append('    set {0}={1}{0}{1}'.format(ret, accessor))

    if ret_output:
        output.append('endlocal & (')
        output.extend(ret_output)
        output.append(')')
    else:
        output.append('endlocal')
    output.append('goto :eof')
    return output
gen_return.regex = re.compile(r'^\s*return(.*)$')


def gen_error(parser, line, match):
    code, msg = match.groups()
    return [code + parser.error_str(msg)]
gen_error.regex = re.compile(r'^(.*?)error\("(.*?)"\)\s*$')

def gen_debug(parser, line, match):
    code, msg = match.groups()
    return [code + parser.debug_str(msg)]
gen_debug.regex = re.compile(r'^(.*?)debug\("(.*?)"\)\s*$')

def gen_call(parser, line, match):
    code, is_protected, call_line = match.groups()
    is_protected = is_protected == 'p'
    output = []
    output.append(code + 'call {call_line}'.format(call_line=call_line))
    if not is_protected:
        output.append(code + 'if not "%ERROR_MSG%" == "" if "%CALL_STACK%" == "" goto :_Error')
        output.append(code + 'if not "%ERROR_MSG%" == "" ' + parser.pass_error())
    return output
gen_call.regex = re.compile(r'^(.*?)(p|n)call (.*?)$')

def gen_remove_comment(parser, line, match):
    return []
gen_remove_comment.regex = re.compile(r'^\s*@?rem.*$', re.I)


def gen_include(parser, line, match):
    varname, path = match.groups()
    include_path = os.path.join(os.path.dirname(parser.path), path)
    include_path = os.path.normpath(os.path.abspath(include_path))
    if varname:
        # include to variable
        varname = varname.strip()
        chars = ['set {}='.format(varname)]
        with open(include_path, 'r', encoding='utf-8') as fp:
            context = fp.read()
        for c in context:
            chars.append(INLINE_CHARMAP.get(c, c))
        return [''.join(chars)]
    elif include_path not in parser.toplevel.includes:
        parser.toplevel.includes.append(include_path)
        return [Parser.parsefile(include_path, toplevel=parser.toplevel, debug=parser.debug)]
    else:
        return []
gen_include.regex = re.compile(r'^.*?#include\((?:(.*?),\s*)?"(.*?)"\)\s*$')


line_handlers = [gen_return, gen_error, gen_debug, gen_call, gen_remove_comment, gen_include]



def gen_function(parser, block, match):
    '''
    1. fixed argument:                NAME
    2. optional argument:             NAME=
    3. optional switch default off:   NAME=N
    4. optional switch default on:    NAME=Y
    5. optional keyed argument:       NAME=?
    6. optional keyed argument:       NAME=VALUE
    7. variable argument:             NAME=...
    8. varargs with origin:           NAME=....
    8. varargs with no quote:         NAME=.....

    example:
    ::: function download(Url, Output=, Cookie=?, SkipExists=N, Key=Value, Args=...)

    '''
    defline, funcname, parameters, extensions, delayedexpansion, body = match.groups()

    # re-indent body
    if all(line.startswith('    ') for line in body.split('\n') if line.strip()):
        body = '\n'.join(line[4:] for line in body.split('\n'))

    # add return at body end
    body += '\nreturn'

    extensions = bool(extensions)
    delayedexpansion = bool(delayedexpansion)
    output = []
    output.extend((ln if ln.startswith(':::') else '::: ' + ln) for ln in defline.split('\n'))

    def enterlocal():
        output.append('@setlocal {} {}'.format(
            'enableextensions' if extensions else '',
            'enabledelayedexpansion' if delayedexpansion else ''))
        if not parser.debug:
            output.append('@echo off')
        output.append('@set ERROR_MSG=')
        output.append('@set ERROR_SOURCE=')
        output.append('@set ERROR_BLOCK=')
        output.append('@set ERROR_LINENO=')
        output.append('@set ERROR_CALLSTACK=')

    # nature enter
    enterlocal()
    output.append('goto :REALBODY_{funcname}'.format(funcname=funcname))

    # call enter
    output.append(':{funcname}'.format(funcname=funcname))
    enterlocal()
    output.append('set CALL_STACK={funcname} %CALL_STACK%'.format(funcname=funcname))
    output.append('goto :REALBODY_{funcname}'.format(funcname=funcname))

    # fianl enter
    output.append(':REALBODY_{funcname}'.format(funcname=funcname))

    parameters = [p.strip().split('=',1) for p in parameters.replace('\n', '').split(',')]
    parameters = [param for param in parameters if param != ['']]
    for param in parameters[:]:
        if len(param) == 1:
            # fixed
            output.append('set {}=%~1'.format(param[0]))
            output.append('if "%1" == ""' + parser.error_str('Need argument {}'.format(param[0]), blockname=funcname))
            output.append('shift')
        elif param[1] == '':
            # optional
            output.append('set test=%~1')
            output.append('if not "%test:~0,1%" == "-" (')
            output.append('    set {}=%~1'.format(param[0]))
            output.append('    shift')
            output.append(')')
            output.append('set test=')
        else:
            # keyword
            break
        parameters.pop(0)

    for param in parameters:
        name, value = param
        if value == 'N':
            output.append('set {}=0'.format(name))
        elif value == 'Y':
            output.append('set {}=1'.format(name))
        elif value in ['?', '...', '....', '.....']:
            output.append('set {}='.format(name))
        else:
            output.append('set {}={}'.format(name, value))

    output.extend([
        '',
        ':ArgCheckLoop_{}'.format(funcname),
        'set head=%~1',
        'set next=%~2',
        '',
        'if "%head%" == "" goto :GetRestArgs_{}'.format(funcname),
        'if "%next%" == "" set next=__NONE__',
        '',
    ])


    varargs = None
    for param in parameters:
        if varargs:
            raise Exception('varargs must be last parameters')
        name, value = param
        prefixname = name.lower().replace('_', '-')
        if value == 'N':
            output.append('@if "%head%" == "--{}" @('.format(prefixname))
            output.append('    @set {}=1'.format(name))
            output.append('    @shift')
            output.append('    @goto :ArgCheckLoop_{}'.format(funcname))
            output.append(')')
        elif value == 'Y':
            output.append('@if "%head%" == "--{}" @('.format(prefixname))
            output.append('    @set {}=0'.format(name))
            output.append('    @shift')
            output.append('    @goto :ArgCheckLoop_{}'.format(funcname))
            output.append(')')
        elif value == '...':

            output.append('@goto :GetRestArgs_{}'.format(funcname))
            varargs = name
            varargs_quote = True
        elif value == '....':
            output.append('@goto :GetRestArgs_{}'.format(funcname))
            varargs = name
            varargs_quote = 'Origin'
        elif value == '.....':
            output.append('@goto :GetRestArgs_{}'.format(funcname))
            varargs = name
            varargs_quote = False
        elif value:
            output.append('@if "%head%" == "--{}" @('.format(prefixname))
            output.append('    @set {}=%next%'.format(name))
            output.append('    @if "%next%" == "__NONE__"' + parser.error_str('Need value after "%head%"', blockname=funcname))
            output.append('    @if "%next:~0,1%" == "-"' + parser.error_str('Need value after "%head%"', blockname=funcname))
            output.append('    @shift')
            output.append('    @shift')
            output.append('    @goto :ArgCheckLoop_{}'.format(funcname))
            output.append(')')

    output.append('')
    if not varargs:
        output.append(parser.error_str('Unkwond option "%head%"', blockname=funcname))
    output.append(':GetRestArgs_{funcname}'.format(funcname=funcname))


    if varargs:
        varargs_symbol = ('"%~1"' if varargs_quote is True else
                          '%1' if varargs_quote == 'Origin' else
                          '%~1')
        output.extend("""
@set {varargs}={varargs_symbol}
@shift
:GetRestArgsLoop_{funcname}
@if "%~1" == "" @goto :Main_{funcname}
@set {varargs}=%{varargs}% {varargs_symbol}
@shift
@goto :GetRestArgsLoop_{funcname}""".format(varargs_symbol=varargs_symbol,
                                            varargs=varargs, funcname=funcname).split('\n'))


    output.append(':Main_{}'.format(funcname))
    output.append('@set head=')
    output.append('@set next=')
    output.append(parser.parseline(body))
    return output



gen_function.regex = re.compile(
    r'(?:^|\n)'
    r'(:+ function ([A-Za-z0-9_-]+)\(([A-Za-z0-9_,\=\?\ \.\n]*)\)(\s+extensions)?(\s+delayedexpansion)?)\n'
    r'(.*?)\n'
    r':+ endfunc', re.MULTILINE | re.DOTALL)


INLINE_CHARMAP = {}
for single_escape in '<>"|&':
    INLINE_CHARMAP[single_escape] = '^' + single_escape
for double_escape in '!':
    INLINE_CHARMAP[double_escape] = '^^' + double_escape
for triple_escape in '^':
    INLINE_CHARMAP[triple_escape] = '^^^' + triple_escape
INLINE_CHARMAP['%'] = '%%'
INLINE_CHARMAP['\n'] = '^\n\n'


def gen_inline(parser, block, match):
    varname, context = match.groups()
    chars = ['set {}='.format(varname)]
    for c in context:
        chars.append(INLINE_CHARMAP.get(c, c))
    return [''.join(chars)]

gen_inline.regex = re.compile(
    r'(?:^|\n)'
    r':+ inline\((.*?)\)\n'
    r'(.*?)\n'
    r':+ endinline', re.MULTILINE | re.DOTALL)

block_handlers = [gen_function, gen_inline]


class Parser:
    def __init__(self, path, toplevel=True, debug=False):
        self.path = path
        self.toplevel = self if toplevel is True else toplevel
        self.debug = debug
        self.includes = []

    @classmethod
    def parsefile(cls, path, toplevel=True, debug=False):
        parser = cls(path, toplevel, debug)
        with open(parser.path, encoding='utf-8') as fp:
            script = fp.read()
            return parser.parse(script)

    def parseline(self, cmdscript):
        lines = []
        for lineno, line in enumerate(cmdscript.split('\n')):
            replace_lines = None
            for body_handler in line_handlers:
                match = body_handler.regex.match(line)
                if match:
                    replace_lines = body_handler(self, line, match)
                    break
            if replace_lines is not None:
                lines.extend(replace_lines)
            else:
                lines.append(line)
        return '\n'.join(lines)


    def parse(self, cmdscript):
        script = cmdscript
        script = script.replace('^\\n^\n', '')
        last_b = 0
        blocks = []

        if self.toplevel is self:
            # add runtime code at start of script
            blocks.append(self.runtime_block_before)
            if self.debug:
                blocks.append("@set DEBUG=1")

        while 1:
            founds = []
            for block_handler in block_handlers:
                match = block_handler.regex.search(script, pos=last_b)
                if match:
                    a, b = match.span()
                    founds.append([a, b, match, block_handler])
            if not founds:
                break
            a, b, match, block_handler = sorted(founds, key=lambda x: x[0])[0]
            origin_block = script[a:b]
            output = block_handler(self, origin_block, match)
            blocks.append(self.parseline(script[last_b:a]))
            blocks.append('\n'.join(output))
            last_b = b

        blocks.append(self.parseline(script[last_b:]))

        if self.toplevel is self:
            # add runtime code at end of script
            blocks.append(self.runtime_block_after)
        return ''.join(blocks)

    def pass_error(self):
        return (' endlocal & ('
                ' set "ERROR_MSG=%ERROR_MSG%" &'
                ' set "ERROR_SOURCE=%ERROR_SOURCE%" &'
                ' set "ERROR_BLOCK=%ERROR_BLOCK%" &'
                ' set "ERROR_LINENO=%ERROR_LINENO%" &'
                ' set "ERROR_CALLSTACK=%ERROR_CALLSTACK%" &'
                ' goto :eof )'
                )

    def error_str(self, msg, lineno=None, blockname=None):
        return (' endlocal & ('
                ' set "ERROR_MSG={}" &'
                ' set "ERROR_SOURCE={}" &'
                ' set "ERROR_BLOCK={}" &'
                ' set "ERROR_LINENO={}" &'
                ' set "ERROR_CALLSTACK=%CALL_STACK%" &'
                ' goto :eof )').format(
            msg,
            os.path.basename(self.path),
            blockname if blockname is not None else '',
            lineno if lineno is not None else '')

    def debug_str(self, msg):
        return ' @if not "%DEBUG%" == "" @echo {}'.format(msg)

Parser.runtime_block_before = """
@set SCRIPT_SOURCE=%~f0
@set SCRIPT_FOLDER=%~dp0
@if "%SCRIPT_FOLDER:~-1%" == "\\" @set SCRIPT_FOLDER=%SCRIPT_FOLDER:~0,-1%

"""

Parser.runtime_block_after = """

:_ProtectError
@goto :eof

:_Error
@echo ERROR: %ERROR_MSG%^

    at %ERROR_SOURCE%:%ERROR_BLOCK%:%ERROR_LINENO%^

    stacktrace: %ERROR_CALLSTACK% 1>&2
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
@exit /b 1

"""


def _test():
    defline = '''
::: function download(Url, Output=, Cookie=?, SkipExists=N)
    abc
    return %a%, !b!, c
::: endfunc
    '''
    for match in gen_function.regex.finditer(defline):
        output = gen_function(*match.groups())
        print('\n'.join(output))



if __name__ == '__main__':
    import sys
    print(Parser.parsefile(sys.argv[1], debug=len(sys.argv) == 3 and sys.argv[2] == '--debug'))
