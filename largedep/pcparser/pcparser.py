import setuptools
import json
from xml.etree import ElementTree as et

"""
project config parser
"""

def parse_setup_py(file):
    class Fake:
        def setup(self, *args, **kwargs):
            self.model = kwargs
    
    fake = Fake()
    _setup = setuptools.setup
    setuptools.setup = fake.setup
    with open(file, 'r') as f:
        exec(f.read())
    setuptools.setup = _setup
    return fake.model
    
def parse_package_json(file):
    with open_universe(path, 'r') as f:
        config = json.load(f)
        return config
    
    
def parse_pom_xml(file)

    ns = "http://maven.apache.org/POM/4.0.0"
    group = artifact = version = ""

    tree = et.ElementTree()
    tree.parse(filename)

    p = tree.getroot().find("{%s}parent" % ns)

    if p is not None:
        if p.find("{%s}groupId" % ns) is not None:
            group = p.find("{%s}groupId" % ns).text

        if p.find("{%s}version" % ns) is not None:
            version = p.find("{%s}version" % ns).text

    if tree.getroot().find("{%s}groupId" % ns) is not None:
        group = tree.getroot().find("{%s}groupId" % ns).text

    if tree.getroot().find("{%s}artifactId" % ns) is not None:
        artifact = tree.getroot().find("{%s}artifactId" % ns).text

    if tree.getroot().find("{%s}version" % ns) is not None:
        version = tree.getroot().find("{%s}version" % ns).text

    return (group, artifact, version)
    
def parse_build_gradle(file):
    os.system('gradle install')
    os.path.join('build/poms', 'pom-default.xml')
    
    
print(parse_setup_py('C:/Users/ran/Documents/GitHub/homo/setup.py'))
