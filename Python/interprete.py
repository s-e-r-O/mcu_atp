import json
import re
import sys
from pprint import pprint

reg_pattern = re.compile(r'^[A-H]$')
val_pattern = re.compile(r'^[0-9]+$')
areg_pattern = re.compile(r'^\[[A-H]\]$')
aval_pattern = re.compile(r'^\[[0-9]+\]$')

separator_pattern = re.compile(r'\s*,\s*|\s+\n?')

config = json.load(open('config.json'))

def recognizeAddress(address):
	if reg_pattern.match(address):
		value = config['reg'][address]
		return 'reg',value
	elif val_pattern.match(address):
		value = int(address)
		if value < 256:
			return 'val',value
		return 'na',0
	elif areg_pattern.match(address):
		value = config['reg'][address[1]]
		return 'areg',value
	elif aval_pattern.match(address):
		value = int(address[1:].partition(']')[0])
		if value < 256:
			return 'aval',value
		return 'na',0
	return 'na',0


src = open('source.txt', 'r')
raw = open('bin.bin', 'wb')

def close():
	src.close()
	raw.close()
	sys.exit()

for line in src:
	line = list(filter(None,separator_pattern.split(line.partition(';')[0].upper())))
	found = False
	if line == []:
		continue
	print(repr(line))
	for cur_command in config['commands']:
		if cur_command['id'] == line[0]:
			cmd = cur_command
			found = True
			break
	
	if not found:
		print('Command not found')
		close()
	
	if cmd['length'] == 1:
		if len(line) != 1:
			print('Not permitted')
			close()
		
		byteData = bytearray([cmd['value']])
		raw.write(byteData)
	elif cmd['length'] == 2: 
		if len(line) != 2:
			print('Not permitted')
			close()
		
		dir_id,value = recognizeAddress(line[1])
		
		if not dir_id in cmd['dir']:
			print ('Not permitted')
			close()
		
		byteData = bytearray([(cmd['dir'][dir_id] << 5) + cmd['value'], value])
		raw.write(byteData)
	else:
		if len(line) != 3:
			print('Not permitted')
			close()

		dir_id1,value1 = recognizeAddress(line[1])
		dir_id2,value2 = recognizeAddress(line[2])
		dir_id = dir_id1 + '-' + dir_id2

		if not dir_id in cmd['dir']:
			print ('Not permitted')
			close()
		
		byteData = bytearray([(cmd['dir'][dir_id] << 5) + cmd['value'], value1, value2])
		raw.write(byteData)
		
close()