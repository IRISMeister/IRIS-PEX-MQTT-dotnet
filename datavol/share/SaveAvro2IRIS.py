import os
import io
import avro.schema
import avro.io
import json

# copy me in mgr\python\
def save(seq,topic,avromsg,extra=''):
	import iris
	#print(iris.cls('%SYSTEM.Version').GetVersion())
	#print(os.getcwd())
	
	# 注意) import irisはカレントを'/usr/irissys/mgr/user'に移動させる
	# コンテナ環境ではファイルを/opt/irisbuild/AVRO/にcopyしているのでpath指定無しでアクセスできる。
	schema = avro.schema.parse(open(extra+'SimpleClass.avsc', 'rb').read())

	bytes_reader = io.BytesIO(avromsg)
	decoder = avro.io.BinaryDecoder(bytes_reader)
	reader = avro.io.DatumReader(schema)

	iris.system.Process.SetNamespace('AVRO')
	sql = "INSERT INTO MQTT.SimpleClass (myArray, myBool, myFilename, myDouble, myFloat, myInt, myLong, myString,seq, topic) VALUES(?,?,?,?,?,?,?,?,?,?)"
	stmt = iris.sql.prepare(sql)

	while bytes_reader.tell() < len(bytes_reader.getvalue()):
		data = reader.read(decoder)
		#print(data)
		with open(data['myFilename'], 'wb') as f:
			f.write(data['myBytes'])
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

	avrofile='SimpleClass.avro'
	fr = open(avrofile, 'rb')
	byte_data = fr.read()	
	seq=1
	topic="mytopic"

	sys.exit(save(seq,topic,byte_data,extra=cwd))
