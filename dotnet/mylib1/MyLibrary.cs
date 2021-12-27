﻿using System;

using InterSystems.Data.IRISClient.Gateway;
//for gateway and NAtive API
using InterSystems.Data.IRISClient.ADO;
//for ADO.NET
using InterSystems.Data.IRISClient;
//for XEP
using InterSystems.XEP;

namespace dc
{
    public class MyLibrary
    {
        EventPersister xepPersister = PersisterFactory.CreatePersister();

	    public IRISObject DoSomethingNative(String mqtttopic, String mqttmsg)
        {
            long seqno;

            // Decode mqttmsg (raw data) into rows. It depends on how they are encoded.
            //
            // ++Write your code here++
            int elementcount = 2000;
            int columncount = 4;

            int[] array = new int[elementcount];
            for (int i = 0; i < elementcount; i++)
            {
                array[i] = i;
            }
            // --Write your code here--


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
                    String Namespace = "INTEROP";
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
            seqno = (long)iris.ClassMethodLong("Solution.RAWDATA", "GETNEWID");
            IRISList list = new IRISList();
            for (int i = 0; i < elementcount; i += columncount)
            {
                list.Clear();
                for (int j = 0; j < columncount; j++) {
                    list.Add(array[i+j]);
                }
                iris.ClassMethodStatusCode("Solution.RAWDATA", "INSERT", seqno, list);
            }

            IRISObject request = (IRISObject)iris.ClassMethodObject("Solution.RAWDATAC", "%New", seqno);

            return request;
        }

        public IRISObject DoSomethingSQL(String mqtttopic, String mqttmsg)
        {
            long seqno;

            // Decode mqttmsg (raw data) into rows. It depends on how they are encoded.
            //
            // ++Write your code here++
            int elementcount = 2000;
            int columncount = 4;

            int[] array = new int[elementcount];
            for (int i = 0; i < elementcount; i++)
            {
                array[i] = i;
            }
            // --Write your code here--


            // Get connection
            // SQL always need its own connection 
            String host = "iris";
            String port = "1972";
            String username = "SuperUser";
            String password = "SYS";
            String Namespace = "INTEROP";
            IRISConnection connection = new IRISConnection();
            connection.ConnectionString = "Server = " + host + "; Port = " + port + "; Namespace = " + Namespace + "; Password = " + password + "; User ID = " + username;
            connection.Open();

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
                iris = IRIS.CreateIRIS(connection);
            }


            seqno = (long)iris.ClassMethodLong("Solution.RAWDATA", "GETNEWID");

            // ADO.NET (relational)
            String sqlStatement = "INSERT INTO Solution.RAWDATA (seq,p1,p2,p3,p4) VALUES (@seq,@p1,@p2,@p3,@p4)";
            IRISCommand cmd = new IRISCommand(sqlStatement, connection);

            seqno = (long)iris.ClassMethodLong("Solution.RAWDATA", "GETNEWID");

            // split array into columns
            for (int i = 0; i < elementcount; i += columncount)
            {
                cmd.Parameters.Clear();
                cmd.Parameters.AddWithValue("@seq", seqno);
                cmd.Parameters.AddWithValue("@p1", array[i]);
                cmd.Parameters.AddWithValue("@p2", array[i + 1]);
                cmd.Parameters.AddWithValue("@p3", array[i + 2]);
                cmd.Parameters.AddWithValue("@p4", array[i + 3]);
                cmd.ExecuteNonQuery();
            }

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
            String Namespace = "INTEROP";
            IRISConnection connection = new IRISConnection();
            connection.ConnectionString = "Server = " + host + "; Port = " + port + "; Namespace = " + Namespace + "; Password = " + password + "; User ID = " + username;
            connection.Open();

            IRIS iris = IRIS.CreateIRIS(connection);
            IRISObject request = (IRISObject)iris.ClassMethodObject("EnsLib.MQTT.Message", "%OpenId", id);

            return request;
        }

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
    }
}
