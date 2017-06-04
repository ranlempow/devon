import os
import sys
import re
import shutil
import configparser
from os.path import join

origin = os.path.abspath(join(__file__, '..', '..'))
base = os.path.expanduser('~\\Desktop')

def get_version(shell_dir):
	with open(join(shell_dir, 'dev-sh.cmd'), 'rb') as fp:
		match = re.search(b'^set DEVON_VERSION=([\d.]+)', fp.read(), re.M)
		if match:
			return match.group(1).decode('utf-8')

def get_config(shell_dir):
	config_file = join(shell_dir, 'devon.ini')
	if os.path.exists(config_file):
		config = configparser.ConfigParser(allow_no_value=True, interpolation=None, strict=False)
		config.read(config_file)
		return config

def iter_shelldirs():
	founds = []
	excludes = ['node_modules', 'apptool', 'brickv']
	count = 0
	for root, dirs, files in os.walk(base):
		dirs[:] = (d for d in dirs if d not in excludes)
		for file in files:
			count += 1
			if count % 1000 == 0:
				print(count)
			if file == 'dev-sh.cmd':
				founds.append(root)

	for shdir in founds:
		config = get_config(shdir)
		version = get_version(shdir)
		yield os.path.relpath(shdir, base), version, config


def cmd_list(root, version, config):
	if config:
		sums = sum(len(config.items(sec)) for sec in config.sections())
	print('{:>7s} ({:>2s} configs) {:s}'.format(version or 'none', str(sums) if config else 'no', root))

def cmd_upgrade(root, version, config):
	import semver
	if not version or not config:
		return
	origin_version = get_version(origin)
	if semver.compare(version, origin_version) < 0:
		shutil.copyfile(join(origin, 'dev-sh.cmd'), join(root, 'dev-sh.cmd'))

def cmd_ignorelist(root, version, config):
	pass

if __name__ == '__main__':
	cmd = sys.argv[1]
	for root, version, config in iter_shelldirs():
		globals()['cmd_' + cmd](root, version, config, *sys.argv[2:])
