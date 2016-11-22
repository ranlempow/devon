import os
import sys
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
import shutil
import zipfile
from largedep import ctask
import largedep

url_tpl = 'https://services.gradle.org/distributions/gradle-{major}.{minor}-bin.zip'


@ctask
def install(ctx, locale=True):
    if not locale:
        # TODO: error
        return
        
    largedep.chdir_to_appdir('gradle')
    file = largedep.download_to_disk(url_tpl.format(major=2, minor=11))
    
    with zipfile.ZipFile(file, mode='r') as zip:
        zip.extractall()
    gradle_home = os.path.basename(file[:-len('-bin.zip')])

    ef = largedep.EnvironmentFile()
    ef.set_env('GRADLE_HOME', gradle_home)
    ef.set_relpath(os.path.join(gradle_home, 'bin'))
    ef.close()
    
    
@ctask
def uninstall(ctx):
    largedep.chdir_to_appdir('gradle')
    os.chdir('..')
    shutil.rmtree('gradle')
