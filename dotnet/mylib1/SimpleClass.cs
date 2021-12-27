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

using Index = InterSystems.XEP.Attributes.Index;
using IndexType = InterSystems.XEP.Attributes.IndexType;

namespace dc
{
[Index(name = "idx1", fields = new string[] { "<myLong>k__BackingField" }, type = IndexType.simple)]
public class SimpleClass
{
   public static string SCHEMA = @"{""protocol"" : ""MyProtocol"",""type"":""record"",""name"":""SimpleClass"",""namespace"":""foo"",""fields"":[{""name"":""myInt"",""type"":""int""},{""name"":""myLong"",""type"":""long""},{""name"":""myBool"",""type"":""boolean""},{""name"":""myDouble"",""type"":""double""},{""name"":""myFloat"",""type"":""float""},{""name"":""myBytes"",""type"":""bytes""},{""name"":""myString"",""type"":""string""},{""name"":""myArray"",""type"":{""type"":""array"",""items"":""bytes""}},{""name"":""myMap"",""type"":{""type"":""map"",""values"":""string""}}]}";

    public int myInt { get; set; }

    public long myLong { get; set; }

    public bool myBool { get; set; }

    public double myDouble { get; set; }

    public float myFloat { get; set; }

    public byte[] myBytes { get; set; }

    public string myString { get; set; }

    public List<byte[]> myArray { get; set; }

    public Dictionary<string, string> myMap { get; set; }

    public static SimpleClass Populate()
    {
        SimpleClass z = new SimpleClass()
        {
            myInt = 1,
            myLong = 2L,
            myBool = true,
            myDouble = 3.14,
            myFloat = (float)1.59E-2,
            myBytes = new byte[8] { 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,},
            myString = "this is a SimpleClass",
            myArray = new List<byte[]>() { new byte[] { 0x01, 0x02, 0x03, 0x04 } },
            myMap = new Dictionary<string, string>()
            {
                ["abc"] = "123"
            }
        };
        return z;
    }        
}
}