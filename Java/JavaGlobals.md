# **Connecting to InterSystem IRIS Hierarchical Model from Java**

This notebook provides a step-by-step guide for Java developers looking to connect to and interact with InterSystems IRIS Hierarchical model.

## Step 1. Prerequisites
Before writing any code, ensure that all necessary components are installed.
|     Component     |   Status  |                           Check                    |
|-------------------|-----------|----------------------------------------------------|
| InterSystems IRIS | Running   | Ensure the IRIS instance is started and accessible |
| JDBC Driver       | Available | Verify that you have intersystems-jdbc.jar file |
| Java project      | Ready     | Your project should be set up in your preferred IDE and include intersystems-jdbc.jar in classpath |

- You can download the jar file from [Driver packages page](https://intersystems-community.github.io/iris-driver-distribution/).
- If InterSystems IRIS is installed on your local machine or another you have access to, you can find the file in install-dir/dev/java/lib/ or similar, where install-dir is the installation directory for the instance.

## Step 2. Forming connection string
The connection string requires three critical pieces of information: the Server location (Host and Port), the target Namespace, and Credentials (UID and PWD):
<pre>String connStr = "jdbc:IRIS://127.0.0.1:1972/USER";
String user = "_SYSTEM";
String pwd = "SYS";                  
</pre>

## Step 3. Writing java code to write a global to InterSystems IRIS
- In the dedicated class add imports:
<pre>import com.intersystems.jdbc.*;
</pre>
- Create and open the connection to the database using the connectionString from Step 2:
<pre>IRISConnection conn = (IRISConnection)java.sql.DriverManager.getConnection(connStr,user,pwd);
</pre>
- Create an IRIS object that will allow to work with globals:
<pre>IRIS global = IRIS.createIRIS(conn); 
</pre>
- Create a global ^Person with two nodes "Doe,John" and "Smith,Jane" and set their dates of birth as values:
<pre>global.set(Date.valueOf("1991-05-26"), "Person", "Doe,John");
global.set(Date.valueOf("1991-05-26"), "Person", "Smith,Jane");
</pre>
To update a value of any node, use the same method.
- Close and release resources:
<pre>global.close();
conn.close();
</pre>


## Step 4. Writing Java code to read all nodes of the global from IRIS DB

- Create an iterator that will allow to get access to all nodes on the first level of the global ^Person:
<pre>IRISIterator iter = global.getIRISIterator("Person");
</pre>
- Iterate over the resultset and print subscript and value:
<pre>while (iter.hasNext()) {
    iter.next();
    System.out.println(iter.getSubscriptValue() + " was born on " + global.getDate("Person", iter.getSubscriptValue())); 
}
</pre>

## Step 5. Writing Java code to read exact node from IRIS DB

- Get the value of the node:
<pre>Date dob = global.getDate("Person", "Smith,Jane");
System.out.println(dob);
</pre>

## Step 6. Writing Java code to delete a node(s) from the DB

- Delete the node:
<pre>global.kill("Person", "Doe,John");
global.kill("Person");
</pre>

## Resulting class
Here's the whole class including exception handling:
<pre>package com.example;

import java.sql.Date;
import java.sql.SQLException;
import com.intersystems.jdbc.*;

public class GlobalsExample {

    public static void main(String[] args) throws Exception {
        
    	//Open a connection to the server and create an IRIS object
        String connStr = "jdbc:IRIS://127.0.0.1:1972/USER";
        String user = "_SYSTEM";
        String pwd = "SYS";
        
        // Use standard JDBC Connection
        try (IRISConnection conn = (IRISConnection)java.sql.DriverManager.getConnection(connStr,user,pwd)){
        	IRIS global = IRIS.createIRIS(conn);   
        	
        	global.set(Date.valueOf("1991-05-26"), "Person", "Doe,John");
        	global.set(Date.valueOf("1991-05-26"), "Person", "Smith,Jane");
        	
        	// Read child nodes in collation order while iter.hasNext() is true
        	try {
        	    IRISIterator iter = global.getIRISIterator("Person");
        	    while (iter.hasNext()) {
        	      iter.next();
        	      System.out.println(iter.getSubscriptValue() + " was born on " + global.getDate("Person", iter.getSubscriptValue())); 
        	    }
        	} catch  (Exception e) {
        	    System.out.println( e.getMessage());
        	}
        	
        	Date dob = global.getDate("Person", "Smith,Jane");
        	System.out.println(dob);
        	
        	global.kill("Person", "Doe,John");
        	global.kill("Person");
        
        	global.close();
            conn.close();

        } catch (SQLException e) {
            System.err.println("\n--- Database Error ---");
            System.err.println("Error Message: " + e.getMessage());
        }
    }
}
</pre>
