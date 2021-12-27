/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

using System;
using System.IO;
using System.Collections.Generic;
using Avro;
using Avro.IO;
using Avro.Generic;
using Avro.Specific;
using Avro.Reflect;

namespace dc
{
    public class ReflectReader
    {
    
    public static T protocol<T>(string s, T value)
    {
        Stream stream;
        Avro.Schema ws;
        serializeByProtocol<T>(s, value, out stream, out ws);

        // save to a file.
        string path = "ComplexClass.avro";
        FileStream fs = new FileStream(
            path, FileMode.Create, FileAccess.Write);
        stream.CopyTo(fs);
        fs.Close();
        stream.Position = 0;
        

        T output = deserialize<T>(stream, ws, ws);
        return output;
    }

    public static T schema<T>(string s, T value)
    {
        Stream stream;
        Avro.Schema ws;
        serializeBySchema<T>(s, value, out stream, out ws);

        // save to a file.
        string path = "SimpleClass.avro";
        FileStream fs = new FileStream(
            path, FileMode.Create, FileAccess.Write);
        stream.CopyTo(fs);
        fs.Close();
        stream.Position = 0;


        T output = deserialize<T>(stream, ws, ws);
        return output;
    }

    public static void serializeBySchema<T>(string writerSchema, T actual, out Stream stream, out Avro.Schema ws)
    {

        ws = Schema.Parse(writerSchema);

        var ms = new MemoryStream();
        Encoder e = new BinaryEncoder(ms);

        ReflectWriter<T> w = new ReflectWriter<T>(ws);

        w.Write(actual, e);
        ms.Flush();
        ms.Position = 0;
        stream = ms;
    }

    public static void serializeByProtocol<T>(string writerSchema, T actual, out Stream stream, out Avro.Schema ws)
    {

        Protocol protocol = Protocol.Parse(writerSchema);
        ws = null;
        foreach (var s in protocol.Types)
        {
            if (s.Name == "ComplexClass")
            {
                ws = s;
            }
        }

        var ms = new MemoryStream();
        Encoder e = new BinaryEncoder(ms);

        ReflectWriter<T> w  = new ReflectWriter<T>(ws);

        w.Write(actual, e);
        ms.Flush();
        ms.Position = 0;
        stream = ms;
    }
        
    public static List<S> decode<S>(byte[] b)
    {
            MemoryStream ms = new MemoryStream();
            ms.Write(b, 0, b.Length);
            ms.Position = 0;

            System.Reflection.FieldInfo field = typeof(S).GetField("SCHEMA");
            string schema=(string)field.GetValue(null);
            Avro.Schema ws = Schema.Parse(schema);
            ReflectReader<S> r = new ReflectReader<S>(ws, ws);
            Decoder d = new BinaryDecoder(ms);

            // Add all record(s) into a list
            var items = new List<S>();

            // Repeat it until ms depleted.
            do { 
                items.Add(  (S)(r.Read(default(S), new BinaryDecoder(ms)))  ); 
            }
            while (ms.Position<ms.Length);
            return items;

    }
        
    public static S deserialize<S>(Stream ms, Avro.Schema ws, Avro.Schema rs)
    {
        //S deserialized = null;
        long initialPos = ms.Position;

        ReflectReader<S> r = new ReflectReader<S>(ws, rs);
        Decoder d = new BinaryDecoder(ms);
        return r.Read(default(S), new BinaryDecoder(ms));
    }
    
    }
}