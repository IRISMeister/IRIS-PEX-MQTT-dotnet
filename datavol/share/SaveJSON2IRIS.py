import os
import io
import avro.schema
import avro.io
import json
import base64

# copy me in mgr\python\
def save(seq,topic,msg,extra=''):
	import iris
	
	iris.system.Process.SetNamespace('AVRO')
	sql = "INSERT INTO MQTT.SimpleClass (myArray, myBool, myFilename, myDouble, myFloat, myInt, myLong, myString,seq, topic) VALUES(?,?,?,?,?,?,?,?,?,?)"
	stmt = iris.sql.prepare(sql)

	json_str = msg.decode('utf-8')
	data = json.loads(json_str)
	
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

	pf = platform.system()
	if pf == 'Windows':
		cwd=os.getcwd()+'\\'
		sys.path += ['c:\\intersystems\\iris\\lib\\python','c:\\intersystems\\iris\\mgr\\python']
	elif pf == 'Linux':
		cwd=os.getcwd()+'/'
		sys.path += ['/usr/irissys/lib/python/','/usr/irissys/mgr/python/']

	avrofile='compare.json'
	fr = open(avrofile, 'rb')
	byte_data = fr.read()	
	seq=1
	topic="mytopic"

	sys.exit(save(seq,topic,byte_data,extra=cwd))
