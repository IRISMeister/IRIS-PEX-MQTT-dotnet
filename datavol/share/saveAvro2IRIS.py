import io,os
import avro.schema
import avro.io

# put me in mgr\python\
def save(seq,topic,avromsg):
	import iris
	# debug 目的のiris機能呼び出し
	print(iris.cls('%SYSTEM.Version').GetVersion())

	schema = avro.schema.parse(open('C:\git\IRIS-PEX-MQTT-dotnet\datavol\share\SimpleClass.avsc', 'rb').read())

	bytes_reader = io.BytesIO(avromsg)
	decoder = avro.io.BinaryDecoder(bytes_reader)
	reader = avro.io.DatumReader(schema)

	iris.system.Process.SetNamespace('AVRO')
	sql = "INSERT INTO MQTT.SimpleClass (myBool, myBytes, myDouble, myFloat, myInt, myLong, myString,seq, topic) VALUES(?,?,?,?,?,?,?,?,?)"
	stmt = iris.sql.prepare(sql)

	while bytes_reader.tell() < len(bytes_reader.getvalue()):
		data = reader.read(decoder)
		print(data)
		try: 
			rs=stmt.execute(int(data['myBool']),data['myBytes'],data['myDouble'],data['myFloat'],data['myInt'],data['myLong'],data['myString'],seq,topic)
		except Exception as ex:
			if ex.sqlcode != 0:
				print ('SQL error', ex.message, ex.sqlcode, ex.statement)

	return 0

if __name__ == '__main__':
	import sys
	sys.path += ['c:\\intersystems\\iris\\lib\\python','c:\\intersystems\\iris\\mgr\\python']
	import iris
	
	fd = os.open('C:\git\IRIS-PEX-MQTT-dotnet\datavol\share\SimpleClass.avro', os.O_RDONLY)
	BUFSIZE = 2**32-1
	byte_data = os.read(fd, BUFSIZE)
	os.close(fd)
	seq=1
	topic="mytopic"
	sys.exit(save(seq,topic,byte_data))
