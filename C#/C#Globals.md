# **Connecting to InterSystem IRIS Hierarchical Model from C# (using ADO.NET)**

This notebook provides a step-by-step guide for C# developers looking to connect to and interact with InterSystems IRIS Hierarchical model using the ADO.NET provider.

## Step 1. Prerequisites
Before writing any code, ensure that all necessary components are installed.
|     Component     |   Status  |                           Check                    |
|-------------------|-----------|----------------------------------------------------|
| InterSystems IRIS | Running   | Ensure the IRIS instance is started and accessible |
| ADO.NET assembly  | Available | You need to have the correct version of the InterSystems IRIS ADO.NET assembly available |
| C# project        | Ready     | Your project should be set up in Visual Studio or your preferred IDE |

- If InterSystems IRIS is installed on the same machine - the file is already present in \dev\dotnet\bin.
- If InterSystems IRIS is installed on a remote server - you must download and install the standalone development package for your operating system and bitness (32-bit or 64-bit) from WRC website if you're a client or by installing development components and copying files from \dev\dotnet\bin manually.

![image.png](images/Ado1.png)

## Step 2. Forming connection string
The connection string requires three critical pieces of information: the Server location (Host and Port), the target Namespace, and Credentials (UID and PWD):
<pre>// Connection String Breakdown
string connectionString =
    "Host=127.0.0.1;" + // Hostname or IP of the IRIS server
    "Port=1972;" +      // SuperServer TCP Port
    "Namespace=USER;" + // Target IRIS Namespace
    "Password=SYS;" +   // Password (Case-Sensitive, if default)
    "User=_System;";    // Username (Case-Insensitive)                  
</pre>

## Step 3. Adding assembly to your project
Right-click Dependencies in your project in Solution Explorer → Add Project Reference…

![image.png](images/Ado2.png)

In the Reference Manager window:
Click Browse… on the bottom right. Locate InterSystems.Data.IRISClient.dll file. Click Add and OK.

![image-2.png](images/Ado3.png)



## Step 4. Writing C# code to write a global to InterSystems IRIS via ADO.NET
- In the dedicated class add links to the assemblies:
<pre>using InterSystems.Data.IRISClient;
using InterSystems.Data.IRISClient.ADO;
</pre>
- Create and open the connection to the database using the connectionString from Step 2:
<pre>// Use the 'using' block to ensure the connection is properly closed, 
// even if errors occur.
using (IRISConnection conn = new IRISConnection(connectionString))
{
    conn.Open();
}
</pre>
- Create an IRIS object that will allow to work with globals:
<pre>IRIS iris = IRIS.CreateIRIS(conn);
</pre>
- Create a global ^Person with two nodes "Doe,John" and "Smith,Jane" and set their dates of birth as values:
<pre>iris.Set(DateTime.Now, "Person", "Doe,John");
iris.Set(DateTime.Now, "Person", "Smith,Jane");
</pre>
To update a value of any node, use the same method.
- Close and release resources:
<pre>iris.Close();
conn.Close();
</pre>

## Step 5. Writing C# code to read all nodes of the global from IRIS DB

- Create an iterator that will allow to get access to all nodes on the first level of the global ^Person:
<pre>IRISIterator iterPeople = iris.GetIRISIterator("Person");
</pre>
- Iterate over the resultset and print subscript and value:
<pre>foreach (byte[] age in iterPeople)
{
    Byte[] name = (Byte[])iterPeople.CurrentSubscript;
    Console.WriteLine("\n"+ Encoding.UTF8.GetString(name) + " was born " + Encoding.UTF8.GetString(age));
}
</pre>

## Step 6. Writing C# code to read exact node from IRIS DB

- Get the value of the node:
<pre>DateTime dob = (DateTime)iris.GetDateTime("Person", "Doe,John");
Console.WriteLine("Person(\"Doe,John\")=" + dob.ToString("yyyy-MM-dd"));
</pre>

## Step 7. Writing C# code to delete a node(s) from the DB

- Delete the node:
<pre>iris.kill("Person", "Doe,John");
iris.Kill("Person");
</pre>


## Resulting class
Here's the whole class including exception handling:
<pre>using InterSystems.Data.IRISClient;
using InterSystems.Data.IRISClient.ADO;
using System.Text;

namespace NativeSpace
{
    class NativeDemo
    {
        static void Main(string[] args)
        {
            try
            {
                //Open a connection to the server and create an IRIS object
                IRISConnection conn = new IRISConnection();
                conn.ConnectionString = "Host=127.0.0.1;Port=1972;Namespace=USER;" +
                                        "Password=SYS;User=_System;";
                conn.Open();
                IRIS iris = IRIS.CreateIRIS(conn);

                //Create a global array in the USER namespace on the server
                iris.Set(DateTime.Now, "Person", "Doe,John");
                iris.Set(DateTime.Now, "Person", "Smith,Jane");

                
                // Iterate over all nodes on the first level and print subscripts and node values
                Console.WriteLine("\nPeople in the DB: ");
                IRISIterator iterPeople = iris.GetIRISIterator("Person");
                foreach (byte[] age in iterPeople)
                {
                    Byte[] name = (Byte[])iterPeople.CurrentSubscript;
                    Console.WriteLine("\n"+ Encoding.UTF8.GetString(name) + " was born " + Encoding.UTF8.GetString(age));
                }

                // Read the values from the database and print them
                DateTime dob = (DateTime)iris.GetDateTime("Person", "Doe,John");
                Console.WriteLine("Person(\"Doe,John\")=" + dob.ToString("yyyy-MM-dd"));

                //Delete the global array and terminate
                iris.Kill("Person"); // delete global array root
                iris.Close();
                conn.Close();
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }
        }
    } 
}
</pre>
