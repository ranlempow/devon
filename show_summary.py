import os
import re

status_re = re.compile(r'^\s*([A-za-z0-9-.]+):\s*([0-9]+%|O|X|\.)\s*$', re.MULTILINE)

#print(status_re.match(' abc: 100% ').groups())
#print(status_re.match(' abc:    . ').groups())



AttrNameList = [
	'system',
	'global',
	'validate',
	'patchmoved',
	'static-version',
	'newest-version',
	'multi-version',
	'semver',
]

AttrShortName = {
	'system':'sys',
	'global':'glob',
	'validate':'valid',
	'patchmoved':'pmove',
	'static-version':'st-v',
	'newest-version':'new-v',
	'multi-version':'mul-v',
	'semver':'sem-v',
}

AttrWeightV10 = {
	'system':0.2,
	'global':0.2,
	'validate':0.1,
	'patchmoved':0.1,
	'static-version':0.3,
	'newest-version':0.2,
}
AttrWeightV11 = {
	'system':0.2,
	'global':0.2,
	'validate':0.1,
	'patchmoved':0.1,
	'static-version':0.3,
	'newest-version':0.2,
	'multi-version':0.3,
	'semver':0.2,
}


def iter_app_attrs(root='./larges'):
	for app_name in os.listdir(root):
		app_attrs = dict((n, '.') for n in AttrNameList)
		app_attrs['name'] = app_name
		app_readme = os.path.join(root, app_name, 'readme.md')
		if os.path.exists(app_readme):
			text = open(app_readme, encoding='utf-8').read()
			for m in status_re.finditer(text):
				attrname, value = m.groups()
				if value.endswith('%'): value = int(value.strip('%'))
				if attrname in AttrNameList:
					app_attrs[attrname] = value
			yield app_attrs

def print_prog():
	print('')
	print(('{:12s}{:>6s}{:>6s}' + '{:>6s}' * len(AttrNameList)).format('----APP----', 'v1.0', 'v1.1', *(AttrShortName[n] for n in AttrNameList)))
	for app_attrs in iter_app_attrs():
		text = ''.join('{:>6s}'.format(str(app_attrs[n])) for n in AttrNameList)
		v10_prog = 0
		v10_weight = 0
		v11_prog = 0
		v11_weight = 0
		for attr, value in app_attrs.items():
			if attr not in AttrNameList:
				continue
			if value == '.':
				continue
			if value == 'O':
				value = 100
			if value == 'X':
				value = 0
			value = int(value)

			if attr in AttrWeightV10:
				v10_prog += (value / 100.0) * AttrWeightV10[attr]
				v10_weight += AttrWeightV10[attr]
			if attr in AttrWeightV11:
				v11_prog += (value / 100.0) * AttrWeightV11[attr]
				v11_weight += AttrWeightV11[attr]

		v10_weighted_prog = 0 if v10_weight == 0 else v10_prog / v10_weight
		v11_weighted_prog = 0 if v11_weight == 0 else v11_prog / v11_weight
		print('{:12s}{:>5d}%{:>5d}%{}'.format(app_attrs['name'], int(v10_weighted_prog * 100), int(v11_weighted_prog * 100), text))

if __name__ == '__main__':
	print_prog()
