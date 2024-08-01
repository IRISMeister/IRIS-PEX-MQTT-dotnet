using System;

using InterSystems.Data.IRISClient.Gateway;
//for gateway and NAtive API
using InterSystems.Data.IRISClient.ADO;
//for ADO.NET
using InterSystems.Data.IRISClient;
//for XEP
//using InterSystems.XEP;

namespace dc
{
    public class MyLibrary
    {
        //EventPersister xepPersister = PersisterFactory.CreatePersister();

	    public IRISObject DoSomethingNative(String mqtttopic, String mqttmsg)
        {
            long seqno;

            // Get connection
            IRIS iris = null;
            try
            {
                // any better way than try-catch ?
                iris = GatewayContext.GetIRIS();
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());

                Console.WriteLine("Establishing new connection.");
                try {
                    // consider we are not in External gateway server context
                    String host = "iris";
                    String port = "1972";
                    String username = "SuperUser";
                    String password = "SYS";
                    String Namespace = "AVRO";
                    IRISConnection connection = new IRISConnection();
                    connection.ConnectionString = "Server = " + host + "; Port = " + port + "; Namespace = " + Namespace + "; Password = " + password + "; User ID = " + username;
                    connection.Open();

                    iris = IRIS.CreateIRIS(connection);
                }
                catch (Exception e2)
                {
                    Console.WriteLine(e2.ToString());

                }
            }
            // Native API
            // Save decoded values into IRIS via Native API
            seqno = (long)iris.ClassMethodLong("MQTT.RAWDATA", "GETNEWID");
            //IRISList list = new IRISList();
            String list="[1,2,3]";
            iris.ClassMethodLong("MQTT.RAWDATA", "INSERT", seqno, "mytopic",list,list);

            IRISObject request = (IRISObject)iris.ClassMethodObject("MQTT.RAWDATAC", "%New", seqno);

            return request;
        }

        public IRISObject DoSomethingSQL(String mqtttopic, String mqttmsg)
        {
            long seqno;

            IRISConnection connection = null;
            IRIS iris = null;
            try
            {
                iris = GatewayContext.GetIRIS();
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
                // consider we are not in External gateway server context
                Console.WriteLine("Establishing new connection.");
                // Get connection
                // SQL always need its own connection 
                String host = "iris";
                String port = "1972";
                String username = "SuperUser";
                String password = "SYS";
                String Namespace = "AVRO";
                connection = new IRISConnection();
                connection.ConnectionString = "Server = " + host + "; Port = " + port + "; Namespace = " + Namespace + "; Password = " + password + "; User ID = " + username;
                connection.Open();
                iris = IRIS.CreateIRIS(connection);
            }

            seqno = (long)iris.ClassMethodLong("MQTT.RAWDATA", "GETNEWID");

            // ADO.NET (relational)
            String sqlStatement = "INSERT INTO MQTT.RAWDATA (seq,l1,l2,l3,l4) VALUES (@seq,@p1,@p2,@p3,@p4)";
            IRISCommand cmd = new IRISCommand(sqlStatement, connection);

            seqno = (long)iris.ClassMethodLong("MQTT.RAWDATA", "GETNEWID");

            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@seq", seqno);
            cmd.Parameters.AddWithValue("@p1", 1);
            cmd.Parameters.AddWithValue("@p2", 2);
            cmd.Parameters.AddWithValue("@p3", 3);
            cmd.Parameters.AddWithValue("@p4", 4);
            cmd.ExecuteNonQuery();

            // Return a message.
            IRISObject request = (IRISObject)iris.ClassMethodObject("Ens.StringContainer", "%New", seqno);
            return request;
        }

        public int GetNumber() { return 123; }

	    public String TestArray()
        {
            int elementcount = 2000;

            int[] array = new int[elementcount];
            for (int i = 0; i < elementcount; i++)
            {
                array[i] = i;
            }

            // Get connection
            IRIS iris = null;
            iris = GatewayContext.GetIRIS();

            return String.Join(",",array);
        }

        public IRISObject GetEnsLibMQTT(int id)
        {
            String host = "iris";
            String port = "1972";
            String username = "SuperUser";
            String password = "SYS";
            String Namespace = "AVRO";
            IRISConnection connection = new IRISConnection();
            connection.ConnectionString = "Server = " + host + "; Port = " + port + "; Namespace = " + Namespace + "; Password = " + password + "; User ID = " + username;
            connection.Open();

            IRIS iris = IRIS.CreateIRIS(connection);
            IRISObject request = (IRISObject)iris.ClassMethodObject("EnsLib.MQTT.Message", "%OpenId", id);

            return request;
        }
/*
        public void XEPImport(string classFullName)
        {
            XEPConnect();
            xepPersister.ImportSchema(classFullName);   // import flat schema
            XEPClose();
        }   
        public void XEPConnect()
        {
            //EventPersister xepPersister = PersisterFactory.CreatePersister();

            String host = "iris";
            int port = 1972;
            String username = "SuperUser";
            String password = "SYS";
            String Namespace = "INTEROP";
            xepPersister.Connect(host, port, Namespace, username, password); 
        } 
        public void XEPClose()
        {
            xepPersister.Close();
        }
        public void XEP(string classFullName, dc.SimpleClass e)
        {
            // Calling ImportSchema() everytime may not a good idea.
            xepPersister.ImportSchema(classFullName);   // import flat schema
            Event xepEvent = xepPersister.GetEvent(classFullName, Event.INDEX_MODE_SYNC);
            xepEvent.Store(e);
            xepEvent.Close();
        } 
*/       
    }
}
