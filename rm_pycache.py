import os
import shutil
targets = []
for root, dirs, files in os.walk('C:/Users/ran/Desktop/big_depend/bin/python-3.4.4'):
    for dir in dirs:
        if dir == '__pycache__':
            targets.append(os.path.join(root, dir))
            
for dir in targets:
    shutil.rmtree(dir)
    print('remove {}'.format(dir))
    