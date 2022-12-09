using System;
using InterSystems.Data.IRISClient.Gateway;
using InterSystems.Data.IRISClient.ADO;

namespace dc
{
    public class MQTTOperationNoOp : InterSystems.EnsLib.PEX.BusinessOperation
    {

        public override void OnTearDown() { } // Abstract method in PEX superclass. Must override.
        public override void OnInit() { } // Abstract method in PEX superclass. Must override.

        public override object OnMessage(object request)
        {
            LOGINFO("Message Received");
            IRISObject req = (IRISObject)request;
            LOGINFO("Received object: " + req.InvokeString("%ClassName", 1));

            //Do whatever you want.

            return null;
        }

    }
}
