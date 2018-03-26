import json
import re
import sys
import serial
import time

reg_pattern = re.compile(r'^[A-H]$')
val_pattern = re.compile(r'^[0-9]+|\w+$')
areg_pattern = re.compile(r'^\[[A-H]\]$')
aval_pattern = re.compile(r'^\[([0-9]+|\w+)\]$')

separator_pattern = re.compile(r'\s*,\s*|\s+\n?')
label_pattern = re.compile(r'^(\s)*(?![A-H|a-h]\W|[0-9]+)(\w+)(\s)*:')

config = json.load(open('config.json'))

variables = {}

num_line = 0

num_instruction = 0

src = open('source.txt', 'r')
raw = open('source.bin', 'wb')

def recognizeAddress(address):
	if reg_pattern.match(address):
		value = config['reg'][address]
		return 'reg',value
	elif val_pattern.match(address):
		value = getValue(address)
		if (value == None):
			return 'na',0
		return 'val', value
	elif areg_pattern.match(address):	
		value = config['reg'][address[1]]
		return 'areg',value
	elif aval_pattern.match(address):
		value = getValue(address[1:].partition(']')[0])
		if (value == None):	
			return 'na',0
		return 'aval',value
	return 'na',0

def getValue(address):
	try:
		value = int(address)
	except:
		if (variables.get(address) != None):
			value=variables[address]
		else:
			print('(' + str(num_line) + '): '+address+' doesn\'t exist')
			close(False)

	if value < 256:
		return value
	return None

def close(keepExec):
	src.close()
	raw.close()
	if not keepExec:
		sys.exit()


print('Finding all variables...')
#Find all variables
for line in src:

	num_line+= 1

	# Check for labels
	if label_pattern.match(line):
		if (re.match(r'^(\s)*[0-9]+',line.partition(':')[2])):
			# If label value is numeric
			variables[list(filter(None,separator_pattern.split(line.partition(':')[0])))[0].upper()] = int(list(filter(None,separator_pattern.split(line.partition(':')[2])))[0])
			continue
		# If label value is an instruction
		variables[list(filter(None,separator_pattern.split(line.partition(':')[0])))[0].upper()] = num_instruction
		line = line.partition(':')[2]
	else:
		# Can't have numeric labels or a register value as a label
		if (re.match(r'(\s)*([A-H|a-h]|[0-9]+)(\s)*:', line)):
			print('\t(' + str(num_line) + '): Label not supported')
			close(False)

	line = list(filter(None,separator_pattern.split(line.partition(';')[0].upper())))
	found = False
	if line == []:
		continue
	for cur_command in config['commands']:
		if cur_command['id'] == line[0]:
			cmd = cur_command
			found = True
			break
	
	if not found:
		print('\t(' + str(num_line) + '):Command not found')
		close(False)
	num_instruction += cmd['length']
for var in variables:
	print('\t' + var + ":\t" + str(variables[var]))
src.seek(0)
num_line = 0
print ('Generating .bin file...')	
for line in src:

	num_line+= 1

	# Check for labels
	if label_pattern.match(line):
		if (re.match(r'^(\s)*[0-9]+',line.partition(':')[2])):
			# If label value is numeric
			continue
		line = line.partition(':')[2]
	
	line = list(filter(None,separator_pattern.split(line.partition(';')[0].upper())))
	found = False
	if line == []:
		continue
	print('\t'+repr(line))
	for cur_command in config['commands']:
		if cur_command['id'] == line[0]:
			cmd = cur_command
			found = True
			break
	
	if not found:
		print('\t(' + str(num_line) + '):Command not found')
		close(False)
	num_instruction += cmd['length']
	if cmd['length'] == 1:
		if len(line) != 1:
			print('\t(' + str(num_line) + '):Not permitted')
			close(False)
		
		byteData = bytearray([cmd['value']])
		raw.write(byteData)
	elif cmd['length'] == 2: 
		if len(line) != 2:
			print('\t(' + str(num_line) + '):Not permitted')
			close(False)
		
		dir_id,value = recognizeAddress(line[1])
		
		if not dir_id in cmd['dir']:
			print ('\t(' + str(num_line) + '):Not permitted')
			close(False)
		
		byteData = bytearray([(cmd['dir'][dir_id] << 5) + cmd['value'], value])
		raw.write(byteData)
	else:
		if len(line) != 3:
			print('\t(' + str(num_line) + '):Not permitted')
			close(False)

		dir_id1,value1 = recognizeAddress(line[1])
		dir_id2,value2 = recognizeAddress(line[2])
		dir_id = dir_id1 + '-' + dir_id2

		if not dir_id in cmd['dir']:
			print ('\t(' + str(num_line) + '):Not permitted')
			close(False)
		
		byteData = bytearray([(cmd['dir'][dir_id] << 5) + cmd['value'], value1, value2])
		raw.write(byteData)
close(True)


print('Generating .vhd file...')
vhdl = open('source.vhd', 'w')
with open('source.bin', 'rb') as f:
    byte = f.read(1)
    reg_number = 0
    while byte:
        # Do stuff with byte.
        vhdl.write("\t" + str(reg_number) + " => X\"" + byte.hex() + "\",\n")
        reg_number += 1
        byte = f.read(1)
vhdl.close();
print('\tNumber of registers written: ' + str(reg_number))

print('Sending data through serial port')
ser = serial.Serial('COM19', 115200, timeout=1)
with open('source.bin', 'rb') as f:
    byte = f.read(1)
    reg_number = 0
    while byte:
        # Do stuff with byte.
        ser.write(byte)
        byte = f.read(1)
        time.sleep(1)
print('All done!')