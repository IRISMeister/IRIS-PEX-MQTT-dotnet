import os
import io
import avro.schema
import avro.io
import json
import base64

def init():
	import iris
	iris.system.Process.SetNamespace('AVRO')

# copy me in mgr\python\
def save(seq,topic,msg,extra=''):
	import iris
	
	json_str = msg.decode('utf-8')
	data = json.loads(json_str)

	sql = "INSERT INTO MQTT.SimpleClass (myArray, myBool, myFilename, myDouble, myFloat, myInt, myLong, myString,seq, topic) VALUES(?,?,?,?,?,?,?,?,?,?)"
	stmt = iris.sql.prepare(sql)
	
	with open(data['myFilename'], 'wb') as f:
		f.write(base64.b64decode(data['myBytes']))
	try: 
		rs=stmt.execute(json.dumps(data['myArray']),int(data['myBool']),data['myFilename'],data['myDouble'],data['myFloat'],data['myInt'],data['myLong'],data['myString'],seq,topic)
	except Exception as ex:
		if ex.sqlcode != 0:
			print ('SQL error', ex.message, ex.sqlcode, ex.statement)

	return 0

if __name__ == '__main__':
	import platform
	import sys
	import time

	args = sys.argv
	pf = platform.system()
	if pf == 'Windows':
		datadir="/datavol/share/"
		sys.path += ['c:\\intersystems\\iris\\lib\\python','c:\\intersystems\\iris\\mgr\\python']
	elif pf == 'Linux':
		datadir="/datavol/share/"
		sys.path += ['/usr/irissys/lib/python/','/usr/irissys/mgr/python/']

	jsonfile=datadir+'compare.json'
	fr = open(jsonfile, 'rb')
	byte_data = fr.read()
	topic="/XGH/EKG/ID_123/PYJSON/"
	init()

	start = time.time()

	if 2 <= len(args):
		if args[1].isdigit():
			for seq in range (0,int(args[1])):
				save(seq+1,topic+str(seq+1),byte_data)
	else:
		save(1,topic+'1',byte_data)

	t = time.time() - start
	print(t)