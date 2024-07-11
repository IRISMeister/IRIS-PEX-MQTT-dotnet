import io,os
import avro.schema
import avro.io

# put me in mgr\python\
def save(avromsg):
	import iris
	print(iris.cls('%SYSTEM.Version').GetVersion())

	schema = avro.schema.parse(open('C:\git\IRIS-PEX-MQTT-dotnet\datavol\share\SimpleClass.avsc', 'rb').read())

	bytes_reader = io.BytesIO(avromsg)
	decoder = avro.io.BinaryDecoder(bytes_reader)
	reader = avro.io.DatumReader(schema)

	while bytes_reader.tell() < len(bytes_reader.getvalue()):
		data = reader.read(decoder)
		print(data)
	return 0

if __name__ == '__main__':
	import sys
	sys.path += ['c:\\intersystems\\iris\\lib\\python','c:\\intersystems\\iris\\mgr\\python']
	import iris
	
	fd = os.open('C:\git\IRIS-PEX-MQTT-dotnet\datavol\share\SimpleClass.avro', os.O_RDONLY)
	BUFSIZE = 2**32-1
	byte_data = os.read(fd, BUFSIZE)
	os.close(fd)
	sys.exit(save(byte_data))
