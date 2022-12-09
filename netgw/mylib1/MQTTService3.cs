using System;
using System.IO;
using System.Collections.Generic;
using InterSystems.Data.IRISClient.Gateway;
using InterSystems.Data.IRISClient.ADO;

namespace dc
{
    public class MQTTService3 : InterSystems.EnsLib.PEX.BusinessService
    {
        public string TargetConfigNames;

        public override void OnTearDown() { } // Abstract method in PEX superclass. Must override.
        public override void OnInit() { } // Abstract method in PEX superclass. Must override.

        public override object OnProcessInput(object request)
        {
            long seqno;

            IRISObject req = (IRISObject)request;
            LOGINFO("Received object: " + req.InvokeString("%ClassName", 1));

            String value = req.GetString("StringValue");
            LOGINFO("Received StringValue: " + value);

            String topic = req.GetString("Topic");
            LOGINFO("Received topic: " + topic);

            // Decode AVRO
            byte[] b = req.GetBytes("StringValue");
            List<dc.SimpleClass> items = dc.ReflectReader.decode<dc.SimpleClass>(b);

            IRIS iris = GatewayContext.GetIRIS();
            IRISObject newrequest;
            IRISList myarray = new IRISList();
            foreach (dc.SimpleClass simple in items)
            {
                // get unique value via Native API
                seqno = (long)iris.ClassMethodLong("Solution.SimpleClass", "GETNEWID");

                myarray.Clear();
                for (int j = 0; j < simple.myArray.Count; j++) {
                    myarray.Add(String.Join(",",simple.myArray[j]));
                }

                // Pass an array as a comma separated String value.
                newrequest = (IRISObject)iris.ClassMethodObject("Solution.SimpleClass", "%New", topic,seqno,simple.myInt,simple.myLong,simple.myBool,simple.myDouble,simple.myFloat,String.Join(",",simple.myBytes),simple.myString,myarray);
                // Iterate through target business components and send request message
                string[] targetNames = TargetConfigNames.Split(',');
                foreach (string name in targetNames)
                {
                    LOGINFO("Target:" + name);
                    SendRequestAsync(name, newrequest);
                }
            }
            return null;
        }

    }
}
