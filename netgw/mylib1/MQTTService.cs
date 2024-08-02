using System;
using System.IO;
using System.Collections.Generic;
using InterSystems.Data.IRISClient.Gateway;
using InterSystems.Data.IRISClient.ADO;

namespace dc
{
    public class MQTTService : InterSystems.EnsLib.PEX.BusinessService
    {
        public string TargetConfigNames;

        public override void OnTearDown() { } // Abstract method in PEX superclass. Must override.
        public override void OnInit() { } // Abstract method in PEX superclass. Must override.

        public override object OnProcessInput(object request)
        {
            long seqno;

            IRISObject req = (IRISObject)request;
            //LOGINFO("Received object: " + req.InvokeString("%ClassName", 1));

            String value = req.GetString("StringValue");
            //LOGINFO("Received StringValue: " + value);

            String topic = req.GetString("Topic");
            //LOGINFO("Received topic: " + topic);

            // Decode AVRO
            byte[] b = req.GetBytes("StringValue");
            List<dc.SimpleClass> items = dc.ReflectReader.decode<dc.SimpleClass>(b);

            IRIS iris = GatewayContext.GetIRIS();
            IRISObject newobject,newrequest;

            seqno=iris.Increment(1,"seq");
            foreach (dc.SimpleClass item in items)
            {

                // Save bytes as a O/S file
                /*
                using (FileStream fs = new FileStream(item.myFilename, FileMode.Create, FileAccess.ReadWrite))
                {
                    fs.Write(item.myBytes, 0, item.myBytes.Length);
                }                
                */

                long? rowid = iris.ClassMethodLong("MQTT.RAWDATA", "INSERT", seqno, topic, "["+String.Join(",",item.myBytes)+"]","["+String.Join(",",item.myArray)+"]");
            }
/*
            newrequest = (IRISObject)iris.ClassMethodObject("MQTT.REQ.Simple", "%New", seqno,topic);
            // Iterate through target business components and send request message
            string[] targetNames = TargetConfigNames.Split(',');
            foreach (string name in targetNames)
            {
                //LOGINFO("Target:" + name);
                SendRequestAsync(name, newrequest);
            }
*/            
            return null;
        }

    }
}
