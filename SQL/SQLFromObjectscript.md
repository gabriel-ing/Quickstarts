
# Running SQL Queries from server-side code

## Embedded SQL
You can run SQL queries and transactions using objectscript in several ways. The simplest is Embedded SQL, this is only suitable for simple queries:

```
&sql(SELECT Name INTO :n FROM Sample.Person)
write "name is: ", n
```

## Dynamic SQL:

If you need to create a query at runtime which involves a variable, you might be best using dynamic SQL. A basic example of this is shown below: 

```

ClassMethod BasicDynamicSQL(numOutput as %Integer, minAge as %Integer) As %Status{
  
  // Create SQL Query as string. Replace variables with ?
  set myquery = "SELECT TOP ? Name,DOB FROM Sample.Person WHERE Age < ?"
 
  // Create %SQL.Statement object  
  set tStatement = ##class(%SQL.Statement).%New()
 
  // Prepare Query
  set qStatus = tStatement.%Prepare(myquery)
  
  // If query preparation fails, write error 
  if qStatus'=1 {
	   write "%Prepare failed:" 
	   do $System.Status.DisplayError(qStatus) 
	   quit
   }
  // Execute the query, passing in parameters for placeholder ?
  set rset = tStatement.%Execute(numOutput, minAge)
  
  do rset.%Display()
  
  write !,"End of data" 
}
```

### Using a Query component

You can use a query component within an IRIS class to run a query:

```sql
Class packagename.SQLQuery Extends %RegisteredObject
{
  Query ByName (pStartsWith As %String) As %SQLQuery [ sqlProc ] 
  {
      SELECT ID, NAME,
      FROM sample.Patient
      WHERE (Name %STARTSWITH @pStartsWith)
  }
  ClassMethod UseQueryByName(name As %String){
      Set statement = ##class(%SQL.Statement).%New()
      Set status = statement.%PrepareClassQuery("Sample.Patient", "ByName")
      If $$$ISERR(Status){
        Do $system.OBJ.DisplayError(status)
      }
      
      Set rs = Statement.%Execute(name)
      
      While rs.%Next(){
        print(rs.get("ID"), rs.get("NAME"))
      }
      Do rs.%Close()
  }
}
```

This method of running a SQL query in ObjectScript can be effective for creating complex queries.


### Run SQL file

If you have a file containing SQL commands, you can run it from ObjectScript with the following command: 

```
  DO $SYSTEM.SQL.Schema.ImportDDL("c:\InterSystems\mysqlcode.txt",,"IRIS")
```



### SQL in Embedded Python 

You can use SQL in Embedded Python using `iris.sql`.

Embedded SQL: 
```python
import iris
rs = iris.sql.exec("SELECT Name FROM packagename.Person")
```

Dynamic SQL: 
``` python
import iris
# Use ? as a placeholder
stmt = iris.sql.prepare("SELECT Name, Age FROM packagename.Person WHERE Age > ?" )

# pass in argument(s) for placeholder
age = 25
rs = stmt.execute(age)
```

This will return a Python list of lists, you can iterate as follows: 

```python
for row in rs: 
	 print(row)
	 

- ["John Smith", 30]
- ["Jane Doe",31 ]
```


