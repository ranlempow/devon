import os
import sys
from os.path import join
import urllib.request
import shutil
from urllib.parse import urlparse
from html.parser import HTMLParser
from invoke import ctask

import zipfile
import tarfile


class RefreshHTMLParser(HTMLParser):
    #<META HTTP-EQUIV="Refresh" CONTENT="0;URL=http://ftp.yzu.edu.tw/...">
    def handle_starttag(self, tag, attrs):
        if tag.lower() == 'meta':
            attrdict = dict((k.lower(), v)for k, v in attrs)
            if 'http-equiv' in attrdict and attrdict['http-equiv'].lower() == 'refresh':
                self.url = attrdict['content'].split(';')[-1].split('=', 2)[1]
            

def download_to_disk(url, locale_dir=None, filename=None):
    
    
    def reporthook(blocknum, bs, read, size):
        # 富含動畫的回報掛勾
        animate = ['-', '\\', '|', '/']
        if read != size:
            anim = animate[blocknum % 4]
        else:
            anim = '*'
            
        if size > 0:
            percent = int(read*100/size)
        else:
            percent = 0
        
        print_url = url
        if len(print_url) > 60:
            print_url = print_url[-60:]
            
        output = "{:3d}% {} <- {}".format(percent, anim, print_url)
        sys.stdout.write(output)
        if anim != '*':
            sys.stdout.write("\b" * len(output))
        else:
            sys.stdout.write('\n')
        sys.stdout.flush()
        
        
    with urllib.request.urlopen(url) as response:
        if 'text/html' in response.getheader('Content-Type', ''):
            data = response.read()
            parser = RefreshHTMLParser()
            parser.feed(data.decode('utf-8'))
            return download_to_disk(parser.url, locale_dir, filename)
            
        if not filename:
            disposition = response.getheader('Content-Disposition', None)
            if disposition and disposition.startswith('attachment; filename='):
                filename = disposition.split('attachment; filename=')[1].strip('"')
            else:
                filename = urlparse(url).path.split('/')[-1]
        dest = os.path.join(locale_dir or '.', filename)
        
        with open(dest, 'wb') as out_file:
            bs = 1024*8
            size = int(response.getheader('Content-Length', -1))
            read = 0
            blocknum = 0
            
            if reporthook:
                reporthook(blocknum, bs, read, size)

            while True:
                block = response.read(bs)
                if not block:
                    break
                read += len(block)
                out_file.write(block)
                blocknum += 1
                if reporthook:
                    reporthook(blocknum, bs, read, size)
        
        if size >= 0 and read < size:
            raise urllib.request.ContentTooShortError(
                "retrieval incomplete: got only %i out of %i bytes"
                % (read, size), filename)
            
            
        return dest
    

def extractall_with_renamedir(zip_path, dest_path, new_name):
    if zip_path.endswith('.zip'):
        opener = zipfile.ZipFile
    else:
        opener = tarfile.open
        
    new_path = join(dest_path, new_name)
    with opener(zip_path) as zip:
        firstlevel = set([n.split('/')[0] for n in zip.namelist()])
        if len(firstlevel) == 1:
            # 有根目錄
            root = list(firstlevel)[0]
            zip.extractall(dest_path)
            os.rename(join(dest_path, root), new_path)
        else:
            os.makedirs(new_path)
            zip.extractall(new_path)
    return new_path
    
    
def utf8_open(chain=open):
    def _open(file, *args, **kwargs):
        return chain(file, *args, encoding='utf8', **kwargs)
    return _open
    
def detect_newline_open(chain=open):
    def _open(file, *args, **kwargs):
        with open(file, 'rb') as f:
            data = f.read(10 * 1024)
            if b'\r' not in data:
                newline = '\n'
            elif b'\n' not in data:
                newline = '\r'
            else:
                newline = '\r\n'
        return chain(file, *args, newline=newline, **kwargs)
    return _open
    
def ensure_parent_open(chain=open):
    def _open(file, *args, **kwargs):
        dir = os.path.dirname(file)
        os.makedirs(dir, exist_ok=True)
        return chain(file, *args, **kwargs)
    return _open

DEFAULT_BASE='.homo'

def chdir_to_base(base=DEFAULT_BASE):
    for i in range(100):
        if base in os.listdir(os.getcwd()):
            os.chdir(base)
            return
        os.chdir('..')
    raise Exception("directory '{}' not found".format(base))
    
def chdir_to_appdir(name, base=DEFAULT_BASE):
    chdir_to_base(base)
    
    appdir = os.path.join('apps', name)
    if not os.path.exists(appdir):
        os.makedirs(appdir)
    os.chdir(appdir)
    
def relative_from_base(base=DEFAULT_BASE):
    cwd = os.getcwd()
    chdir_to_base(base)
    base = os.getcwd()
    os.chdir(cwd)
    return os.path.relpath(cwd, start=base)
    
class EnvironmentFile:
    DEFAULT_ENV_PATH = 'setenv.cmd'
    def __init__(self, path=DEFAULT_ENV_PATH):
        self.comment = '@rem'
        self.path = path
        
        def parse(fp):
            last_key = None
            start_line = 0
            for end_line, line in enumerate(fp):
                if line.startswith(self.comment):
                    key = line[len(self.comment):].strip(' \r\n')
                    if last_key is not None:
                        yield (last_key, start_line, end_line)
                    last_key = key
                    start_line = end_line
            if last_key is not None:
                yield (last_key, start_line, end_line)
                
        
        self.content = {}
        with detect_newline_open(utf8_open)(self.path, 'r') as fp:
            for key, start, end in parse(fp):
                self.content[key] = (start, end)
                
                
    def set_env(self, k, v):
        self.fp.write('set {}={}\n'.format(k, v.replace('/', '\\')))
        
        
    def set_path(self, p):
        self.fp.write('set PATH={};%PATH%\n'.format(p.replace('/', '\\')))
        
    def set_relpath(self, p):
        p = '%~dp0{}'.format(p.replace('/', '\\'))
        self.set_path(p)
        
    def close(self):
        self.fp.close()
        
        
'''
projects:
    .env    環境設定檔
    .homo    
        venv    python虛擬環境
        cache?
        apps
            tasks.py
            appX
                tasks.py
                application.json
                config.yaml
            depandencyX
                tasks.py

'''

class Dependency:
    def __init__(self):
        #self.name = None
        #self.arch = None
        #self.system = None
        #self.version = None
        #self.dependencies = []
        pass
        
    def check(local=True):
        pass
        
    def install(local=True):
        # change cwd
        pass
        
    def uninstall(local=True):
        pass
        
        
    def set_env(self, key, value):
        pass
    
    def add_path(self, path):
        pass
        
        