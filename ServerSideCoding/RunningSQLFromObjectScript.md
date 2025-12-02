# Using SQL in Server-Side Code

## ObjectScript
### Embedded SQL
You can run SQL queries and transactions using objectscript in several ways. The simplest is Embedded SQL, this is only suitable for simple queries:

```
Class packagename.SQLBasics {

ClassMethod BasicEmbeddedSQL()
{
  &sql(SELECT Name INTO :name FROM packagename.Person WHERE id = 1)
  write "The first entry in the Person table is: ", name, !
}
}
```

For more complicated queries with SQL, you can define and use a cursor. However, it is recommended to use Dynamic SQL, as shown below instead. To read more about Cursor-based embedded SQL, [see the documentation](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GSQL_esql).

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
      FROM packagename.Person
      WHERE (Name %STARTSWITH @pStartsWith)
  }
```

And the following class method in our SQLBasics class: 

```
ClassMethod UseQueryByName(name As %String)
{
    // Create Statement object
    set statement = ##class(%SQL.Statement).%New()
    
    // Prepare Statement 
    set status = statement.%PrepareClassQuery("packagename.SQLQuery", "ByName")
    
    // Handle Errors from Prepare status
    if $$$ISERR(status){
        do $system.OBJ.DisplayError(status)
        quit
    }
    
    // Execute statement
    Set rs = statement.%Execute(name)
      
    // Iterate over rows
    While rs.%Next() {

        // Write properties
        write !, "ID: ", rs.%Get("ID")
        write !, " Name: ", rs.%Get("Name")
        write !, " Age: ", rs.%Get("Age")
        write !
    }

    Do rs.%Close()
}

```

This method of running a SQL query in ObjectScript can be effective for creating complex queries. 

You can also use the query direct as a function by adding Func to the query name:
```
ClassMethod UseQueryByNameFunction(name As %String)
  {
    set rs = ##class(packagename.SQLQuery).ByNameFunc()
    While rs.%Next(){
      write !
      write rs.%Get("ID")_"  "_rs.%Get("Name")_"  "_rs.%Get("Age")
    }
    do rs.%Close()
  }

```

### Run SQL file

If you have a file containing SQL commands, you can run it from ObjectScript with the following command: 

```
  DO $SYSTEM.SQL.Schema.ImportDDL("c:\InterSystems\mysqlcode.txt",,"IRIS")
```

## SQLCODE

Anytime SQL is run from ObjectScript, a built-in variable called SQLCODE is set to an Integer. This is set to: 

- 0 : successful Completion
- 100 : no data is retrieved (without error)
- < 0 : Error Code

SQLCODE can be used in error handling.



## Embedded Python

The usage in Embedded Python is similar to ObjectScript. We have the option between Embedded SQL and Dynamic SQL. We can also use SQL queries as defined [above](#using-a-query-component)

To access Dynamic or Embedded SQL, we import `iris` and use `iris.sql`

### Embedded SQL:
```
ClassMethod PythonEmbeddedSqlExample() [language = python]{
  import iris
  rs = iris.sql.exec("SELECT Name FROM packagename.Person")
  print(rs)
  for row in rs:
    print(row)
}
```
```
["John Smith"]
["Jane Doe"]
```

### Dynamic SQL:

```
ClassMethod PythonDynamicSqlExample() [ language = python]
{
  import iris
  # Use ? as a placeholder
  stmt = iris.sql.prepare("SELECT Name, Age FROM packagename.Person WHERE Age > ?" )

  # pass in argument(s) for placeholder
  age = 20
  rs = stmt.execute(age)
  # This will return a Python list of lists, you can iterate as follows:

  for row in rs: 
    print(row)

}
```
This outputs:
```
["John Smith", 25]
["Jane Doe", 28 ]
```

