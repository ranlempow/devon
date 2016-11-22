import os
import importlib
from invoke import Collection, ctask
from invoke.program import Program

base = os.path.dirname(__file__)

namespace = Collection('largedep')

for dirname in os.listdir(os.path.join(base, 'larges')):
    name = 'larges.{}.tasks'.format(dirname)
    try:
        mod = importlib.import_module(name)
        namespace.add_collection(Collection.from_module(mod), dirname)
    except:
        pass
        

@ctask(help={'app': '哈哈', 'locale': '123'})
def install(ctx, app, locale=True, version=None):
    """
    些東西安裝一些東西
    
    安裝一些東西
    安裝一些東西
    安裝一些東西
    安裝一些東西
    安裝一些東西
    安裝一些東西
    安裝一些東西
    安裝一些東西
    安裝一些東西
    安裝一些東西
    """
    
namespace.add_task(install)

if __name__ == '__main__':
    prog = Program(namespace=namespace)
    prog.run()