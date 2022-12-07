using System;
using System.Collections.Generic;
using InterSystems.Data.IRISClient.Gateway;
using InterSystems.Data.IRISClient.ADO;

namespace dc
{
    public class MQTTOperation : InterSystems.EnsLib.PEX.BusinessOperation
    {

        public override void OnTearDown() { } // Abstract method in PEX superclass. Must override.
        public override void OnInit() { } // Abstract method in PEX superclass. Must override.

        public override object OnMessage(object request)
        {
            LOGINFO("Message Received");
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

            foreach (dc.SimpleClass simple in items)
            {
                //Do whatever you want.

            }
            return null;
        }

    }
}
