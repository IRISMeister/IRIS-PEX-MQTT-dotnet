import io,os
import avro.schema
import avro.io

schema = avro.schema.parse(open("SimpleClass.avsc", "rb").read())

fd = os.open('SimpleClass.avro', os.O_RDONLY)
BUFSIZE = 2**32-1
byte_data = os.read(fd, BUFSIZE)
os.close(fd)

bytes_reader = io.BytesIO(byte_data)
decoder = avro.io.BinaryDecoder(bytes_reader)
reader = avro.io.DatumReader(schema)

while bytes_reader.tell() < len(bytes_reader.getvalue()):
    data = reader.read(decoder)
    print(data)
