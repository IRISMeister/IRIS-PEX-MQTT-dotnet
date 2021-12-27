using System;
using System.IO;
using System.Linq;
using Avro.IO;
using System.Collections.Generic;
using Avro.Generic;

namespace dc
{
public class GenericReader
{
	public GenericReader()
	{
	}

    public static T test<T>(string s, T value)
    {
        Stream ms;
        Avro.Schema ws;
        serialize(s, value, out ms, out ws);
        Avro.Schema rs = Avro.Schema.Parse(s);
        T output = deserialize<T>(ms, ws, rs);
        return output;
    }

    private static S deserialize<S>(Stream ms, Avro.Schema ws, Avro.Schema rs)
    {
        long initialPos = ms.Position;
        GenericReader<S> r = new GenericReader<S>(ws, rs);
        Decoder d = new BinaryDecoder(ms);
        var items = new List<S>();
        // validate reading twice to make sure there isn't some state that isn't reset between reads.
        items.Add(Read(r, d));
        items.Add(Read(r, d));
        checkAlternateDeserializers(items, ms, initialPos, ws, rs);
        return items[0];
    }

    private static S Read<S>(DatumReader<S> reader, Decoder d)
    {
        S reuse = default(S);
        return reader.Read(reuse, d);
    }

    private static void checkAlternateDeserializers<S>(IEnumerable<S> expectations, Stream input, long startPos, Avro.Schema ws, Avro.Schema rs)
    {
        input.Position = startPos;
        var reader = new GenericDatumReader<S>(ws, rs);
        Decoder d = new BinaryDecoder(input);
        foreach (var expected in expectations)
        {
            var read = Read(reader, d);
        }
    }

    private static void serialize<T>(string writerSchema, T actual, out Stream stream, out Avro.Schema ws)
    {
        var ms = new MemoryStream();
        Encoder e = new BinaryEncoder(ms);
        ws = Avro.Schema.Parse(writerSchema);
        GenericWriter<T> w = new GenericWriter<T>(ws);
        // write twice so we can validate reading twice
        w.Write(actual, e);
        w.Write(actual, e);
        ms.Flush();
        ms.Position = 0;
        checkAlternateSerializers(ms.ToArray(), actual, ws);
        stream = ms;
    }
    private static void checkAlternateSerializers<T>(byte[] expected, T value, Avro.Schema ws)
    {
        var ms = new MemoryStream();
        var writer = new GenericDatumWriter<T>(ws);
        var e = new BinaryEncoder(ms);
        writer.Write(value, e);
        writer.Write(value, e);
        var output = ms.ToArray();

    }

}
}