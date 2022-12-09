using System;
using System.IO;
using System.Collections.Generic;
using InterSystems.Data.IRISClient.Gateway;
using InterSystems.Data.IRISClient.ADO;

namespace dc
{
    public class MQTTService4 : InterSystems.EnsLib.PEX.BusinessService
    {
        dc.MyLibrary mylib = new dc.MyLibrary();
        public string TargetConfigNames;

        public override void OnTearDown() { 
            mylib.XEPClose();
        } // Abstract method in PEX superclass. Must override.

        public override void OnInit() { 
            mylib.XEPConnect();
        } // Abstract method in PEX superclass. Must override.

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

            // Can't send XEP(dotnet) class as is.  So we need to create a simple message class which referes to it.
            IRIS iris = GatewayContext.GetIRIS();
            IRISObject newrequest;
            foreach (dc.SimpleClass simple in items)
            {
                // Save decoded data into IRIS via XEP
                mylib.XEP("dc.SimpleClass", simple);

                // Use myLong as an unique key. 
                seqno = simple.myLong;
                // Save a container message into IRIS via Native API
                newrequest = (IRISObject)iris.ClassMethodObject("Solution.SimpleClassC", "%New", topic,seqno);
                
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
