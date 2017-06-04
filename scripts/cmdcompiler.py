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
        ret_output.append('set "{0}={1}{0}{1}"'.format(ret, accessor))

    return [('endlocal & (if "%EMSG%" == "" ('
             + (('\n' + '\n'.join(ret_output) + '\n') if ret_output else '') +
             'goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))')]

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
        output.append(code + 'if not "%EMSG%" == "" if "%CTRA%" == "" goto :_Error')
        output.append(code + 'if not "%EMSG%" == "" ' + parser.pass_error())
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
    1. fixed argument:                    NAME
    2. optional argument:                 NAME=
    3. optional switch default off:       NAME=N
    5. optional keyed argument(require):  NAME=?
    6. optional keyed argument:           NAME=VALUE
    7. variable argument:                 NAME=...
    8. varargs with origin:               NAME=....
    8. varargs with no quote:             NAME=.....

    example:
    ::: function download(Url, Output=, Cookie=?, SkipExists=N, Key=Value, Args=...)

    '''
    defline, funcname, parameters, extensions, delayedexpansion, body = match.groups()

    # re-indent body
    if all(line.startswith('    ') for line in body.split('\n') if line.strip()):
        body = '\n'.join(line[4:] for line in body.split('\n'))

    # # add return at body end
    body += '\nreturn'

    extensions = bool(extensions)
    delayedexpansion = bool(delayedexpansion)
    output = []
    output.extend((ln if ln.startswith(':::') else '::: ' + ln) for ln in defline.split('\n'))

    extensions = True
    delayedexpansion = True
    output.append(':{funcname}'.format(funcname=funcname))
    output.append('@setlocal {} {}'.format(
        'enableextensions' if extensions else '',
        'enabledelayedexpansion' if delayedexpansion else ''))
    if not parser.debug:
        output.append('@echo off')
    output.append('@set "EMSG=" & set "ESRC=" & set "ETRA="')
    output.append('@set "CSRC={file} {func}" & set "CTRA={func} %CTRA%"'.format(
                  func=funcname, file=os.path.basename(parser.path)))

    parameters = [p.strip().split('=',1) for p in parameters.replace('\n', '').split(',')]
    parameters = [param for param in parameters if param != ['']]

    any_require_option = False
    fixed_min = 0
    fixed_parameters = []
    for param in parameters[:]:
        if len(param) == 1:
            # fixed
            fixed_min += 1
            parameters.pop(0)
            fixed_parameters.append(param)
        elif param[1] == '':
            # optional
            parameters.pop(0)
            fixed_parameters.append(param)
            output.append('set {}='.format(param[0]))
        elif param[1] == '?':
            any_require_option = True

    output.append('@( set _pos=0' +
                  ' & set _fmin={})'.format(fixed_min))

    for param in parameters:
        name, value = param
        if value == 'N':
            output.append('set {}='.format(name))
        elif value in ['?', '...', '....', '.....']:
            output.append('set {}='.format(name))
        else:
            output.append('set {}={}'.format(name, value))


    output.extend([
        '',
        ':parg_{}'.format(funcname),
    ])
    if any_require_option:
        output.extend([
            'if defined _require (',
            '    if "!_next!" == "" goto :parg_noarg_err',
            '    if "!_next:~0,1!" == "-" goto :parg_noarg_err',
            '    set _require=',
            ')',
        ])
    output.extend([
        'set _head=%~1',
        'set _next=%~2',
        # '@echo [!_head!][!_next!] 1>&2',
        '@if not defined _head goto :pargdone_{}'.format(funcname),
    ])


    varargs = None
    varargs_quote = 'Origin'
    for param in parameters[:]:
        if varargs:
            raise Exception('varargs must be last parameters')

        name, value = param
        prefixname = name.lower().replace('_', '-')
        if value == 'N':
            output.append('@if "!_head!" == "--{}"'.format(prefixname) +
                          ' @(set "{}=1"'.format(name) +
                          ' & shift' +
                          ' & goto :parg_{})'.format(funcname))

        elif value == '...':
            varargs = name
            varargs_quote = True
        elif value == '....':
            varargs = name
            varargs_quote = 'Origin'
        elif value == '.....':
            varargs = name
            varargs_quote = False
        elif value:
            output.append('@if "!_head!" == "--{}"'.format(prefixname) +
                          ' @(set "{}=!_next!"'.format(name) +
                          ' & shift & shift' +
                          ' & set _require=1' +
                          ' & goto :parg_{})'.format(funcname))

    if not varargs:
        output.append('@if "!_head:~0,1!" == "-"'
                      # ' if not "!_head:~2,3!" == ""'
                      ' goto :parg_optover_err')

    fixed_count=0
    for param in fixed_parameters:
        output.append('@if %_pos% == {}'.format(fixed_count) +
                      ' @(set "{}=!_head!"'.format(param[0]) +
                      ' & shift' +
                      ' & set /a "_pos+=1"' +
                      ' & goto :parg_{})'.format(funcname))
        fixed_count +=1

    output.append(('@if defined _rest @('
                   '    set _rest=!_rest! {0}'
                   ') else ('
                   '    set _rest={0}'
                   ')').format(
                        '"%~1"' if varargs_quote is True else
                        '%1'    if varargs_quote == 'Origin' else
                        '%~1'))
    output.append('@shift')
    output.append('@goto :parg_{}'.format(funcname))


    output.append(':pargdone_{}'.format(funcname))
    if fixed_min > 0:
        output.append('@if %_pos% LSS %_fmin% goto :parg_posunder_err')
    if varargs:
        output.append('set "{}=!_rest!"'.format(varargs))
    else:
        output.append('@if defined _rest goto :parg_posover_err')
    output.append('@( set "_head="'
                  ' & set "_next="'
                  ' & set "_require="'
                  ' & set "_pos="'
                  ' & set "_fmin="'
                  ' & set "_rest=")')

    output.append(':Main_{}'.format(funcname))
    output.append(parser.parseline(body))
    return output



gen_function.regex = re.compile(
    r'(?:^)'
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
    r'(?:^)'
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
        return (' endlocal & (if "%EMSG%" == "" (goto :eof) else ('
                'set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))')

    def error_str(self, msg, lineno=None, blockname=None):
        return ' endlocal & (set "EMSG={}" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)'.format(msg)

    def debug_str(self, msg):
        return ' @if not "%DEBUG%" == "" @echo {}'.format(msg)

Parser.runtime_block_before = """
@set SCRIPT_SOURCE=%~f0
@set SCRIPT_FOLDER=%~dp0
@if "%SCRIPT_FOLDER:~-1%" == "\\" @set SCRIPT_FOLDER=%SCRIPT_FOLDER:~0,-1%

"""

Parser.runtime_block_after = """
:parg_noarg_err
endlocal & (set "EMSG=option requires an argument -- %_head%" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)

:parg_posunder_err
endlocal & (set "EMSG=takes %_fmin% positional arguments but %_pos% were given" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)

:parg_posover_err
endlocal & (set "EMSG=too many positional arguments -- %_rest%" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)

:parg_optover_err
endlocal & (set "EMSG=unrecognized option -- %_head%" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)



:_ProtectError
@goto :eof

:_Error
@echo ERROR: %EMSG%^

    at %ESRC%^

    stacktrace: %ETRA% 1>&2
@set "EMSG=" & set "ESRC=" & set "ETRA="
@cmd /s /c exit /b 1
@goto :eof

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
