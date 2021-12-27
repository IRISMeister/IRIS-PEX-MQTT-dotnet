import io
import avro.schema
import avro.io

from avro.datafile import DataFileReader, DataFileWriter

schema = avro.schema.Parse(open("BinaryEncoder.avsc", "rb").read())

writer = avro.io.DatumWriter(schema)
bytes_writer = io.BytesIO()
encoder = avro.io.BinaryEncoder(bytes_writer)
writer.write([1,2,3,4,5,6,7,8,9,10],encoder)

raw_bytes = bytes_writer.getvalue()
print(len(raw_bytes))
print(type(raw_bytes))

f = open('BinaryEncoder.avro', 'wb')
f.write(raw_bytes)
f.close()

bytes_reader = io.BytesIO(raw_bytes)
decoder = avro.io.BinaryDecoder(bytes_reader)
reader = avro.io.DatumReader(schema)
data = reader.read(decoder)

print(data)
