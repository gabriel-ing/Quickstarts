# Using SQL in ObjectScript

### Embedded SQL
You can run SQL queries and transactions using objectscript in several ways. The simplest is Embedded SQL, this is only suitable for simple queries:

```
&sql(SELECT Age INTO :age FROM Sample.Person WHERE Name="John Smith")
write "John Smith is "_age_"Years Old"
```


### Dynamic SQL:

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
It is important to use ? placeholders and the Statement.%Prepare() function for security, as this prevents injection of malicious code in the placeholders.

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
      Set status = statement.%PrepareClassQuery("packagename.SQLQuery", "ByName")
      If $$$ISERR(Status){
        Do $system.OBJ.DisplayError(status)
      }
      
      Set rs = Statement.%Execute(name)
      
      While rs.%Next(){
        write rs.get("ID"), rs.get("NAME")
      }
      Do rs.%Close()
  }
}
```

This method of running a SQL query in ObjectScript can be effective for creating complex queries. 

You can also use the query direct as a function by adding Func to the query name. 
```
Class packagename.UseSQLQuery{
  ClassMethod UseQueryByNameFunction(name As %String)
  {
    set rs = ##class(packagename.SQLQuery).ByNameFunc()
    While rs.%Next(){
      write rs.get("ID"), rs.get("NAME")
    }
    do rs.%Close()
  }
}
```

### Run SQL file

If you have a file containing SQL commands, you can run it from ObjectScript with the following command: 

```
  DO $SYSTEM.SQL.Schema.ImportDDL("c:\InterSystems\mysqlcode.txt",,"IRIS")
```

