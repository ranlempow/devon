import os

import zipfile
import subprocess
from ..largedependency import xxxx

class EclipsePack:
    def install(self):
        
    
def install_eclipse():
    file = download_to_disk(
        "http://www.eclipse.org/downloads/download.php"
        "?file=/technology/epp/downloads/release/luna/SR2/eclipse-java-luna-SR2-win32-x86_64.zip&mirror_id=1207")
       
    with zipfile.ZipFile(file, mode='r') as zip:
        zip.extractall()
    
def set_jdk_home():
    java_home = os.environ['JAVA_HOME']
    relative = os.path.relpath(java_home, start=os.path.join('.', 'eclipse'))
    vm_path = os.path.join(relative, 'bin', 'javaw.exe')
    with utf8_detect_newline_open('eclipse\eclipse.ini', 'r+') as f:
        f.seek(0)
        lines = f.readlines()
        for i, line in enumerate(lines):
            # 在 '-vmargs' 之前插入 ['-vm', vm_path]
            if line.strip('\n') == '-vm':
                if lines[i+1].strip('\n') == '-vmargs':
                    lines.insert(i+1, vm_path + '\n')
                    break
                else:
                    lines[i+1] = vm_path + '\n'
                    break
            if line.strip('\n') == '-vmargs':
                lines.insert(i, '-vm' + '\n')
                lines.insert(i+1, vm_path + '\n')
                break
                
        f.seek(0)
        f.write("".join(lines))
        
def write_workspace():
    text = '''MAX_RECENT_WORKSPACES=1
RECENT_WORKSPACES=..\\\\workspace
RECENT_WORKSPACES_PROTOCOL=3
SHOW_WORKSPACE_SELECTION_DIALOG=false'''
    with ensure_parent_open()('eclipse\configuration\.settings\org.eclipse.ui.ide.prefs', 'w') as f:
        f.write(text + '\n')

def install_plugin():
    base_cmd = [
        'eclipse/eclipse.exe',
        '-nosplash',
        '-application', 'org.eclipse.equinox.p2.director'
    ]
    plugins = [
        # android
        (['https://dl-ssl.google.com/android/eclipse/'], ['com.android.ide.eclipse.adt.feature.feature.group']),
        
        # gradle
        (['http://download.eclipse.org/buildship/updates/e44/releases/1.0'], 
            ['org.eclipse.buildship.feature.group']),
    ]
    
    for repos, groups in plugins:
        cmd = base_cmd + ['-repository', ','.join(repos)]
        cmd += ['-installIU', ','.join(groups)]
        subprocess.check_call(cmd)
        
def write_setting():
    
    bigger = 'org.eclipse.jdt.ui/org.eclipse.jface.textfont=1|Consolas|11.25|0|WINDOWS|1|-15|0|0|0|400|0|0|0|0|3|2|1|49|Consolas;'
    smaller = 'org.eclipse.jdt.ui/org.eclipse.jface.textfont=1|Consolas|9.75|0|WINDOWS|1|-15|0|0|0|400|0|0|0|0|3|2|1|49|Consolas;'
    
    
    setting = [
        ('workspace\.metadata\.plugins\org.eclipse.core.runtime\.settings\org.eclipse.ui.workbench.prefs',
            smaller),
        ('workspace\.metadata\.plugins\org.eclipse.core.runtime\.settings\org.eclipse.jdt.ui.prefs',
            smaller),
        ('workspace\.metadata\.plugins\org.eclipse.core.runtime\.settings\org.eclipse.core.resources.prefs',
            'encoding=UTF-8'),
        ('workspace\.metadata\.plugins\org.eclipse.core.runtime\.settings\org.eclipse.ui.ide.prefs',
            'SHOW_LOCATION=true'),
        ('workspace\.metadata\.plugins\org.eclipse.core.runtime\.settings\com.android.ide.eclipse.adt.prefs',
            'com.android.ide.eclipse.adt.sdk=C\\:\\\\Users\\\\ran\\\\Desktop\\\\big_depend\\\\android_sdk\\\\android-sdk-windows'),
    ]
    for file, line in setting:
        with ensure_parent_open(detect_newline_open(utf8_open()))(file, mode='a') as f:
            f.write(line + '\n')
    
    

install_plugin()
