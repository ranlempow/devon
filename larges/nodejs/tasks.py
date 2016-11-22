"""
node.js install script
"""


import os
from os.path import join, basename
import sys
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
import logging

from collections import OrderedDict
import platform
import shutil
import json


from largedep import ctask
import largedep

def _list_remote():
    url = 'https://nodejs.org/dist/index.json'
    logging.warn('向 {} 取得版本資料'.format(url))
    indexfile = largedep.download_to_disk(url)
    with open(indexfile) as f:
        versionlist = json.load(f)
    return OrderedDict((ver['version'].strip('v'), ver)for ver in versionlist)
    
    
def _list():
    largedep.chdir_to_appdir('nodejs')
    for name in os.listdir():
        if os.path.isdir(name) and name.startswith('v'):
            yield name
            
@ctask
def list_remote(ctx):
    versionlist = _list_remote()
    for ver in versionlist.keys():
        print(ver)

@ctask(name='list')
def pylist(ctx):
    for ver in _list():
        print('  ' + ver)

@ctask        
def use(ctx, version):
    dist_path = 'v{}'.format(version)
    if dist_path in _list():
        largedep.chdir_to_appdir('nodejs')
        ef = largedep.EnvironmentFile()
        ef.set_relpath(dist_path)
    else:
        print('{} not found, try below:'.format(dist_path))
        print()
        pylist(ctx)
        
@ctask
def install(ctx, version='latest', arch=None):
    if not arch:
        if platform.machine() == 'X86':
            arch = 'x86'
        elif platform.machine() == 'AMD64':
            arch = 'x64'
        else:
            raise Exception('unsupport architecture {}'.format(platform.machine()))
            

    if platform.system() == 'Windows':
        files_patten = 'win-{}-msi'
        url_patten = 'https://nodejs.org/dist/v{ver}/win-{arch}/node.exe'
    elif platform.system() == 'linux':
        files_patten = 'linux-{}'
        url_patten = 'https://nodejs.org/dist/v{ver}/node-v{ver}-linux-{arch}.tar.xz'
    else:
        raise Exception('unsupport system {}'.format(platform.system()))
        
    versionlist = _list_remote()
    while version == 'latest':
        version_tuple = [tuple(map(int, v.split('.'))) for v in versionlist.keys()]
        ver = '.'.join(map(str, max(version_tuple)))
        
        if files_patten.format(arch) in versionlist[ver]['files']:
            version = ver
            
    if version not in versionlist:
        raise Exception("version {} of node.js not found".format(version))
        
    if files_patten.format(arch) not in versionlist[version]['files']:
        print(files_patten.format(arch))
        print(versionlist[version]['files'])
        raise Exception("version {} of node.js not support this system or arch".format(version))
        
    # find npm version
    npm_version = versionlist[version]['npm']
    
    
    largedep.chdir_to_appdir('nodejs')
    dist_path = 'v{}'.format(version)
    
    
    ef = largedep.EnvironmentFile()
    node_url = url_patten.format(ver=version, arch=arch)
    node_dist = largedep.download_to_disk(node_url)
    
    if platform.system() == 'Windows':
        os.makedirs(dist_path)
        os.rename(node_dist, join(dist_path, basename(node_dist)))
        
        # download and install npm
        file = largedep.download_to_disk('https://github.com/npm/npm/archive/v{}.zip'.format(npm_version))
        npm_dir = largedep.extractall_with_renamedir(file, dest_path=join(dist_path, 'node_modules/'), new_name='npm')
        
        shutil.copyfile(join(npm_dir, 'bin/npm'), join(dist_path, 'npm'))
        shutil.copyfile(join(npm_dir, 'bin/npm.cmd'), join(dist_path, 'npm.cmd'))
        
        ef.set_relpath(dist_path)
        # TODO: 這個可能需要設定給使用者資料夾中的node_modules
        #ef.set_relpath('node_modules/.bin')
    
    elif platform.system() == 'linux':
        # TODO: linux尚未測試
        # 參考: http://www.thegeekstuff.com/2015/10/install-nodejs-npm-linux
        node_dir = largedep.extractall_with_renamedir(file, dest_path='.', new_name=dist_path)
        ef.set_relpath(dist_path)
        
    else:
        raise Exception('unsupport system {}'.format(platform.system()))
    
    #ctx.run("npm install bower")
    #ctx.run("npm install coffee-script")

@ctask
def uninstall(ctx):
    largedep.chdir_to_appdir('nodejs')
    os.chdir('..')
    shutil.rmtree('nodejs')
    
    