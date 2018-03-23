import json
import re
import sys
from pprint import pprint

reg_pattern = re.compile(r'^[A-H]$')
val_pattern = re.compile(r'^[0-9]+|\w+$')
areg_pattern = re.compile(r'^\[[A-H]\]$')
aval_pattern = re.compile(r'^\[[0-9]+\]$')

separator_pattern = re.compile(r'\s*,\s*|\s+\n?')
label_pattern = re.compile(r'^(\s)*(?![A-H|a-h]\W|[0-9]+)(\w+)(\s)*:')

config = json.load(open('config.json'))

variables = {}

num_line = 0

def recognizeAddress(address):
	if reg_pattern.match(address):
		value = config['reg'][address]
		return 'reg',value
	elif val_pattern.match(address):
		try:
			value = int(address)
		except:
			if (variables.get(address) != None):
				value=variables[address]
			else:
				print('(' + str(num_line) + '): '+address+' doesn\'t exist')
				close()

		if value < 256:
			return 'val',value
		return 'na',0
	elif areg_pattern.match(address):
		value = config['reg'][address[1]]
		return 'areg',value
	elif aval_pattern.match(address):
		try:
			value = int(address[1:].partition(']')[0])
		except:
			if (variables.get(address[1:].partition(']')[0]) != None):
				value=variables[address[1:].partition(']')[0]]
			else:
				print('(' + str(num_line) + '): '+address[1:].partition(']')[0]+' doesn\'t exist')
				close()
				
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

num_instruction = 0

for line in src:

	num_line+= 1
	# Check for labels
	if label_pattern.match(line):
		if (re.match(r'^(\s)*[0-9]+',line.partition(':')[2])):
			variables[list(filter(None,separator_pattern.split(line.partition(':')[0])))[0].upper()] = int(list(filter(None,separator_pattern.split(line.partition(':')[2])))[0])
			continue
		variables[list(filter(None,separator_pattern.split(line.partition(':')[0])))[0].upper()] = num_instruction
		line = line.partition(':')[2]
	else:
		if (re.match(r'(\s)*([A-H|a-h]|[0-9]+)(\s)*:', line)):
			print('(' + str(num_line) + '): Label not supported')
			close()

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
		print('(' + str(num_line) + '):Command not found')
		close()
	num_instruction += cmd['length']
	if cmd['length'] == 1:
		if len(line) != 1:
			print('(' + str(num_line) + '):Not permitted')
			close()
		
		byteData = bytearray([cmd['value']])
		raw.write(byteData)
	elif cmd['length'] == 2: 
		if len(line) != 2:
			print('(' + str(num_line) + '):Not permitted')
			close()
		
		dir_id,value = recognizeAddress(line[1])
		
		if not dir_id in cmd['dir']:
			print ('(' + str(num_line) + '):Not permitted')
			close()
		
		byteData = bytearray([(cmd['dir'][dir_id] << 5) + cmd['value'], value])
		raw.write(byteData)
	else:
		if len(line) != 3:
			print('(' + str(num_line) + '):Not permitted')
			close()

		dir_id1,value1 = recognizeAddress(line[1])
		dir_id2,value2 = recognizeAddress(line[2])
		dir_id = dir_id1 + '-' + dir_id2

		if not dir_id in cmd['dir']:
			print ('(' + str(num_line) + '):Not permitted')
			close()
		
		byteData = bytearray([(cmd['dir'][dir_id] << 5) + cmd['value'], value1, value2])
		raw.write(byteData)
print('Variables: ' + str(variables.items()))
close()