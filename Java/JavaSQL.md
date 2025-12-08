# **Connecting to InterSystem IRIS Relational Model from Java (via JDBC)**

This notebook provides a step-by-step guide for Java developers looking to connect to and interact with InterSystems IRIS SQL using JDBC bridge.

## Step 1. Prerequisites
Before writing any code, ensure that all necessary components are installed.
|     Component     |   Status  |                           Check                    |
|-------------------|-----------|----------------------------------------------------|
| InterSystems IRIS | Running   | Ensure the IRIS instance is started and accessible |
| JDBC Driver       | Available | Verify that you have intersystems-jdbc.jar file |
| Java project      | Ready     | Your project should be set up in your preferred IDE and include intersystems-jdbc.jar in classpath |

- You can download the jar file from [Driver packages page](https://intersystems-community.github.io/iris-driver-distribution/).
- If InterSystems IRIS is installed on your local machine or another you have access to, you can find the file in install-dir/dev/java/lib/ or similar, where install-dir is the installation directory for the instance.

## Step 2. Writing Java code to get data from InterSystems IRIS via JDBC
- In the dedicated class add imports to work with JDBC:
<pre>import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
</pre>
- Create and open the connection to the database:
<pre>String url = "jdbc:IRIS://127.0.0.1:1972/USER";
String user = "_System";
String password = "SYS";
Connection conn = DriverManager.getConnection(url, user, password);
</pre>
- Prepare and execute a SQL statement using PreparedStatement class:
<pre>PreparedStatement pstmt = conn.prepareStatement("SELECT ID, Name, DOB FROM Sample.Person WHERE ID < ?")
int maxId = 5;
pstmt.setInt(1, maxId);
ResultSet rs = pstmt.executeQuery()
</pre>
- Loop throught the result
<pre>while (rs.next()) {
    // Access data by column name
    int id = rs.getInt("ID");
    String name = rs.getString("Name");
    // JDBC automatically handles the mapping of IRIS types to Java types (e.g., Date)
    String dob = rs.getDate("DOB").toString(); 
    System.out.println(String.format("ID: %d, Name: %s, DOB: %s", id, name, dob));
}
</pre>

## Resulting class
Here's the whole class including exception handling:
<pre>package com.example;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
	
public class IrisJdbcConnector {

    public static void main(String[] args) {
        
        // 1. Define the connection details
        String url = "jdbc:IRIS://127.0.0.1:1972/USER";
        String user = "_System";
        String password = "SYS";
        
        int maxId = 5; // Parameter for the query

        // The try-with-resources block ensures all resources are closed automatically
        try (
            // 2. Establish the connection
            Connection conn = DriverManager.getConnection(url, user, password);
            
            // 3. Define the SQL Query using a placeholder (?)
            PreparedStatement pstmt = conn.prepareStatement("SELECT ID, Name, DOB FROM Sample.Person WHERE ID < ?")
        ) {
            System.out.println("Connection to InterSystems IRIS successful!");

            // 4. Bind the parameter value
            pstmt.setInt(1, maxId);

            // 5. Execute the query
            try (ResultSet rs = pstmt.executeQuery()) {
                
                System.out.println("--- Query Results ---");
                
                // 6. Iterate through the results
                while (rs.next()) {
                    // Access data by column name
                    int id = rs.getInt("ID");
                    String name = rs.getString("Name");
                    // JDBC automatically handles the mapping of IRIS types to Java types (e.g., Date)
                    String dob = rs.getDate("DOB").toString(); 
                    
                    System.out.println(String.format("ID: %d, Name: %s, DOB: %s", id, name, dob));
                }
            }
            
        } catch (SQLException e) {
            // 7. Handle JDBC-specific exceptions (e.g., connection failure, invalid SQL)
            System.err.println("\n--- Database Error ---");
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Message: " + e.getMessage());
            System.err.println("Ensure the IRIS server is running and the JDBC driver JAR is in the classpath.");
        } catch (Exception e) {
            System.err.println("\n--- General Error ---");
            System.err.println(e.getMessage());
        }
    }
}
</pre>
