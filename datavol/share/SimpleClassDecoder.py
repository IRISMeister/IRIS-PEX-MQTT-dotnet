import io,os
import avro.schema
import avro.io

schema = avro.schema.parse(open('SimpleClass.avsc', 'rb').read())

fr = open('SimpleClass.avro', 'rb')
byte_data = fr.read()
print(byte_data)

bytes_reader = io.BytesIO(byte_data)
decoder = avro.io.BinaryDecoder(bytes_reader)
reader = avro.io.DatumReader(schema)
print(len(bytes_reader.getvalue()))

while bytes_reader.tell() < len(bytes_reader.getvalue()):
    data = reader.read(decoder)
    print(data)
    bytes_reader.tell()
