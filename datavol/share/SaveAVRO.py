import os
import io
import avro.schema
import avro.io
import json

def getschema(datadir):
	global schema
	schema = avro.schema.parse(open(datadir+'SimpleClass.avsc', 'rb').read())

# copy me in mgr\python\
def save(seq,topic,avromsg):
	import iris
	#print(iris.cls('%SYSTEM.Version').GetVersion())
	#print(os.getcwd())
	# 注意) import irisはカレントを'/usr/irissys/mgr/user'に移動させる

	bytes_reader = io.BytesIO(avromsg)
	decoder = avro.io.BinaryDecoder(bytes_reader)
	reader = avro.io.DatumReader(schema)

	iris.system.Process.SetNamespace('AVRO')
	# python3では、しばしば<UNIMPLEMENTED>ddtab+73^%qaqpsq, <UNIMPLEMENTED>term+84^%qaqpslxでエラーになる(動作することもある)。不安定なのでirispythonを使う。
	sql = "INSERT INTO MQTT.SimpleClass (myArray, myBool, myBytes, myDouble, myFloat, myInt, myLong, myString,seq, topic) VALUES(?,?,?,?,?,?,?,?,?,?)"
	stmt = iris.sql.prepare(sql)

	while bytes_reader.tell() < len(bytes_reader.getvalue()):
		data = reader.read(decoder)
		#with open(data['myFilename'], 'wb') as f:
		#	f.write(data['myBytes'])
		try: 
			rs=stmt.execute(json.dumps(data['myArray']),int(data['myBool']),data['myBytes'],data['myDouble'],data['myFloat'],data['myInt'],data['myLong'],data['myString'],seq,topic)
		except Exception as ex:
			if ex.sqlcode != 0:
				print ('SQL error', ex.message, ex.sqlcode, ex.statement)

	return 0


globalschema=''

if __name__ == '__main__':
	import platform
	import sys
	import time

	global schema
	args = sys.argv
	pf = platform.system()
	if pf == 'Windows':
		datadir="/datavol/share/"
		sys.path += ['c:\\intersystems\\iris\\lib\\python','c:\\intersystems\\iris\\mgr\\python']
	elif pf == 'Linux':
		datadir="/datavol/share/"
		sys.path += ['/usr/irissys/lib/python/','/usr/irissys/mgr/python/']

	avrofile=datadir+'compare.avro'
	fr = open(avrofile, 'rb')
	byte_data = fr.read()	
	topic="/XGH/EKG/ID_123/PYAVRO/"
	getschema(datadir)
	
	start = time.time()

	if 2 <= len(args):
		if args[1].isdigit():
			for seq in range (0,int(args[1])):
				save(seq+1,topic+str(seq+1),byte_data)
	else:
		save(1,topic+'1',byte_data)

	t = time.time() - start
	print(t)