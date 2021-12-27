import io,os
import avro.schema
import avro.io

schema = avro.schema.Parse(open("SimpleClass.avsc", "rb").read())


writer = avro.io.DatumWriter(schema)
bytes_writer = io.BytesIO()
encoder = avro.io.BinaryEncoder(bytes_writer)
data = {'myInt': 1, 'myLong': 2, 'myBool': True, 'myDouble': 3.14, 'myFloat': 0.01590000092983246, 'myBytes': b'\x01\x02\x03\x04\x05\x06\x07\x08', 'myString': 'this is a 1st SimpleClass', 'myArray': [b'\x01\x02\x03\x04'], 'myMap': {'abc': '123'}}
writer.write(data,encoder)
data = {'myInt': 10, 'myLong': 3, 'myBool': True, 'myDouble': 2.71, 'myFloat': 0.01590000092983246, 'myBytes': b'\x11\x12\x13\x14\x15\x16\x17\x18', 'myString': 'this is a 2nd SimpleClass', 'myArray': [b'\x01\x02\x03\x04'], 'myMap': {'def': '999'}}
writer.write(data,encoder)

raw_bytes = bytes_writer.getvalue()
print(len(raw_bytes))
print(type(raw_bytes))

fd = os.open('SimpleClass.avro', os.O_CREAT|os.O_WRONLY)
os.write(fd, raw_bytes)
os.close(fd)

