import avro.schema
from avro.datafile import DataFileReader, DataFileWriter
from avro.io import DatumReader, DatumWriter

schema = avro.schema.parse(open("example.avsc", "rb").read())

writer = DataFileWriter(open("DataFile.avro", "wb"), DatumWriter(), schema)
writer.append([1,2,3,4,5])
writer.close()


reader = DataFileReader(open("DataFile.avro", "rb"), DatumReader())
for user in reader:
    print(user)
reader.close()
