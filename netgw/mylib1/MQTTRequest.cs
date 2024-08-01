using System;

namespace dc
{
    public class  MQTTRequest: InterSystems.EnsLib.PEX.Message {
        public string   topic;
        public long     seq;
        public string   myBytes;
        public string   myArray;

        // Overload class constructor method so that casting from Object class works correctly
        public MQTTRequest(string topic, long seq, string myBytes, string myArray) {
            this.topic=topic;
            this.seq=seq;
            this.myBytes=myBytes;
            this.myArray=myArray;
         }

        public MQTTRequest() { }
    }
}
