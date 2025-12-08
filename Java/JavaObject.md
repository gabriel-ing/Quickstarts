# **Connecting to InterSystem IRIS Object Model from Java (using XEP API)**

This notebook provides a step-by-step guide for Java developers looking to connect to and interact with Object model of InterSystems IRIS using the InterSystems XEP API.

## Step 1. Prerequisites
XEP is a lightweight Java SDK that provides high-performance Java technology for persisting simple to moderately complex object hierarchies. XEP projects the data in Java objects as persistent events (database objects that store a persistent copy of the data fields) in an InterSystems IRIS database. XEP is optimized for applications that must acquire and persist data at the highest possible speed.

Before writing any code, ensure that all necessary components are installed.
|     Component     |   Status  |                           Check                    |
|-------------------|-----------|----------------------------------------------------|
| InterSystems IRIS | Running   | Ensure the IRIS instance is started and accessible |
| 64-bit Java JDK   | Running   | Ensure you're using the correct Java version |
| XEP and JDBC jars | Available | All XEP applications require JAR files intersystems-jdbc.jar and intersystems-xep.jar |
| Java project      | Ready     | Your project should be set up in Visual Studio or your preferred IDE |

- You can download the XEP assembly from [Driver packages page](https://intersystems-community.github.io/iris-driver-distribution/).
- If InterSystems IRIS is installed on your local machine or another you have access to, you can find the file in install-dir/dev/java/lib/ or similar, where install-dir is the installation directory for the instance.

## Step 2. Creating Proxy Class
To be able to work with persistent events, you need to create a class on the client side to generate objects for storage. To do this, create a new class with the following contents:

```java
package com.example;

import java.sql.Date;

public class Person {
	public String name;
	public Date dob;
	
	public Person() {}
    
    Person(String str, Date date) {
        name = str;
        dob = date;
    }
    
    public static Person[] generateSampleData(int objectCount) {
    	Person[] data = new Person[objectCount];
        for (int i=0;i<objectCount;i++) {
            data[i] = new Person("Doe,John"+i, Date.valueOf("1991-05-26"));
        }
        return data;
    }
}
```

## Step 3. Writing Java code to store data in the database
- In the dedicated class add imports of XEP API:
<pre>import com.intersystems.xep.*;
</pre>
- Create objects you wish to store in the database
<pre>// Generate 12 SingleStringSample objects for use as test data
Person[] sampleArray = Person.generateSampleData(12);
</pre>
- Create an EventPersister and connect to the database
<pre>EventPersister xepPersister = PersisterFactory.createPersister();
xepPersister.connect("127.0.0.1",1972,"User","_SYSTEM","SYS"); // connect to localhost
</pre>
- Import schema
<pre>
xepPersister.importSchema("xep.samples.SingleStringSample");   // import flat schema
</pre>
- Create an event and link it to the class
<pre>Event xepEvent = xepPersister.getEvent("xep.samples.Person");
</pre>
- Save 12 created objects of class xep.sample.Person to the database
<pre>xepEvent.Store(sampleArray);
</pre>
- Close and release all resources
<pre>xepEvent.Close();
xepPersister.Close();
</pre>

## Step 4. Writing Java code to read objects from the database using SQL query
- In the same class write a query statement
<pre>String sqlQuery = "SELECT * FROM com_example.Person WHERE %ID BETWEEN ? AND ?";
</pre>
- create an EventQuery and execute it
<pre>EventQuery<Person> xepQuery = xepEvent.createQuery(sqlQuery);
xepQuery.setParameter(1,3);    // assign value 3 to first SQL parameter
xepQuery.setParameter(2,12);   // assign value 12 to second SQL parameter
xepQuery.execute();            // get resultset for IDs between 3 and 12
</pre>
- Print the results
<pre>EventQueryIterator<Person> xepIter = xepQuery.getIterator();
while (xepIter.hasNext()) {
	Person newSample = xepIter.next();
	System.out.println(newSample.name+" was born on "+newSample.dob);
}
</pre>
- Close the query
<pre>xepQuery.close();
</pre>

## Step 5. Writing Java code to read object from the database
- In the same class using the same event get an object by its ID
<pre>Person newSample = (Person)xepEvent.getObject(7);
System.out.println(newSample.name+" was born on "+newSample.dob);
</pre>

## Step 6. Writing Java code to change object in the database
- In the same file using the same event either create a new object and substitute the existing object or take the already read object from step 4 and change its properties and then update the object in the database
<pre>Person newP = new Person("Smith,Jane", Date.valueOf("1991-05-26"));
xepEvent.updateObject(4, newP);
</pre>

## Step 7. Writing Java code to delete an object from the database
- In the same file using the same event use the known ID of an object to delete it from the database
<pre>xepEvent.deleteObject(3);
</pre>

## Resulting class
Here's the whole class:
<pre>package com.example;

import com.intersystems.xep.*;
import java.sql.Date;

public class XEPExample {
	 public static void main(String[] args) throws Exception {
		// Generate 12 Person objects for use as test data
		 Person[] sampleArray = Person.generateSampleData(12);
		 
		 // EventPersister
		 EventPersister xepPersister = PersisterFactory.createPersister();
		 xepPersister.connect("127.0.0.1",1972,"User","_SYSTEM","SYS"); // connect to localhost
		 xepPersister.deleteExtent("com.example.Person");   // remove old test data
		 xepPersister.importSchema("com.example.Person");   // import flat schema
		 
		 // Event
		 Event xepEvent = xepPersister.getEvent("com.example.Person");
		 xepEvent.store(sampleArray);
		 
		 xepEvent.deleteObject(3);
		 System.out.println("Object deleted");
		 
		 Person newP = new Person("Smith,Jane", Date.valueOf("1991-05-26"));
		 xepEvent.updateObject(4, newP);
		 
		 Person person = (Person)xepEvent.getObject(7);
		 if (person != null) {			 
			 person.name = "Doe,Jane";
			 xepEvent.updateObject(7, person);
			 }

		 // EventQuery
		 String sqlQuery = "SELECT * FROM com_example.Person WHERE %ID BETWEEN ? AND ?";
		 EventQuery<Person> xepQuery = xepEvent.createQuery(sqlQuery);
		 xepQuery.setParameter(1,3);    // assign value 3 to first SQL parameter
		 xepQuery.setParameter(2,12);   // assign value 12 to second SQL parameter
		 xepQuery.execute();            // get resultset for IDs between 3 and 12

		 // EventQueryIterator
		 EventQueryIterator<Person> xepIter = xepQuery.getIterator();
		 while (xepIter.hasNext()) {
		    Person newSample = xepIter.next();
		    System.out.println(newSample.name+" was born on "+newSample.dob);
		 }

		 xepQuery.close();
		 xepEvent.close();
		 xepPersister.close();
	 } // end main()
} // end class XepSimple
</pre>
