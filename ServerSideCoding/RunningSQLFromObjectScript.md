# Using SQL in Server-Side Code

## ObjectScript
### Sample Data Set-up

To test the queries and methods in this guide, you may wish to create a demo table, you can do this with the following persistent class. Save and compile the class below in your InterSystems IRIS instance. For instructions on getting set-up, see [Getting InterSystems IRIS with Docker]() and [Setting Up Development Environment with VS Code](). 

```objectscript
Class sample.Person Extends %Persistent{

  Property PersonId As %Integer;
  
  Property FirstName As %String;
 
  Property LastName As %String;
 
  Property Age As %Integer;

ClassMethod Populate(pId as %Integer, pFirstName As %String, pLastName As %String, pAge As %Integer ) as %Status
{
  // Instantiate Person
  set person = ##class(sample.Person).%New()

  // Set Properties
  set person.PersonId = pId
  set person.FirstName = pFirstName
  set person.LastName = pLastName
  set person.Age = pAge
  
  // Save to Database
  set status = person.%Save()
  // Return status
  return status
}

}
```

After compiling the class above, you can run the following in the terminal:

```objectscript
do ##class(sample.Person).Populate(1, "Peter", "Parker", 17)
do ##class(sample.Person).Populate(2, "Diana", "Prince", 25)
do ##class(sample.Person).Populate(3, "Clark", "Kent", 30)
do ##class(sample.Person).Populate(4, "Natasha", "Romanoff", 28)
do ##class(sample.Person).Populate(5, "Bruce", "Wayne", 42)
```

### Embedded SQL
You can run SQL queries and transactions using objectscript in several ways. The simplest is Embedded SQL, this is only suitable for simple queries:

```objectscript
Class packagename.SQLBasics {

  ClassMethod BasicEmbeddedSQL()
  {
      new PersonID, FirstName, LastName, Age

      &sql(
          SELECT PersonID, FirstName, LastName, Age
          INTO :PersonID, :FirstName, :LastName, :Age
          FROM sample.Person
          WHERE PersonID = 1
          )

      write "The first entry in the Person table is: ", FirstName, LastName, !
      // outputs The first entry in the Person table is: PeterParker

  }
}
```

For more complicated queries with SQL, you can define and use a cursor. However, it is recommended to use Dynamic SQL, as shown below instead. To read more about Cursor-based embedded SQL, [see the documentation](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GSQL_esql).

### Dynamic SQL

If you need to create a query at runtime which involves a variable, you might be best using dynamic SQL. A basic example of this is shown below: 

```objectscript
ClassMethod BasicDynamicSQL(numOutput as %Integer, minAge as %Integer) As %Status{
  
  // Create SQL Query as string. Replace variables with ?
  set myquery = "SELECT TOP ? FirstName, LastName FROM sample.Person WHERE Age > ?"
 
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
It is important to use ? placeholders and the Statement.%Prepare() function for security, as this prevents injection of malicious code in the placeholders (SQL injection).

### Using a Query component

You can use a query component within an IRIS class to run a query:

```sql
Class packagename.SQLQuery Extends %RegisteredObject
{
  Query ByName (pStartsWith As %String) As %SQLQuery [ sqlProc ] 
  {
      SELECT PersonID, FirstName, LastName, Age
      FROM sample.Person
      WHERE (Name %STARTSWITH :pStartsWith)
  }
}
```

And the following class method in our SQLBasics class: 

```objectscript
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

This method of running a SQL query in ObjectScript can be effective for creating complex queries and having complete control of the execution or run-time.

You can also use the query direct as a function by adding Func to the query name. This can be preferred for simple, pre-defined queries.

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

