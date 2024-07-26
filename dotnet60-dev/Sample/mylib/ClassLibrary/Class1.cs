using System;

using InterSystems.Data.IRISClient.Gateway;
//for gateway and NAtive API
using InterSystems.Data.IRISClient.ADO;
//for ADO.NET
using InterSystems.Data.IRISClient;

namespace ClassLibrary;
public class Class1
{
		public int GetNumber() { return 123; }

	    public int GetData()
        {
				IRIS iris = null;
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
		    Console.WriteLine(iris);
                }
                catch (Exception e)
                {
                    Console.WriteLine(e.ToString());
                }
				
				IRISObject request=null;
				return 7;

		}

}
