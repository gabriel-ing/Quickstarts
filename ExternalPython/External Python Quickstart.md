## Connecting to IRIS from External Python programs 

The SDK can be installed using pip: 

```
pip install intersystems-irispython
```


You can then connect to IRIS as follows: 

``` python
import iris

server = "localhost"
port = 1972 
namespace = "USER"
username = "_system"
password = "SYS"

connection = iris.connect(server, port, namespace, username, password)
```

From the connection object, you can either create a irispy object to access globals and server-side methods, or create a cursor object to run SQL queries on a database. 

### Running SQL queries

SQL queries on the database can be run with the Python DB-API or with SQL alchemy.

### DB-API

``` python
## Connection from above
connection = iris.connect(server, port, namespace, username, password)

cursor = connection.cursor() 

sql = "SELECT ID, Col1, Col2, Col3 FROM package.TableName"
cursor.execute(sql)

# Fetch next row
results_set = cursor.fetchone() 

# Fetch 5 rows

results_set = cursor.fetchmany(5)

# Fetch all (remaining) rows

results_set = cursor.fetchall() 

```

The results set is a list of lists, but can be easily converted to a pandas dataframe as follows:
``` python
import pandas as pd

df = pd.DataFrame(results_set, columns=["ID", "Col1", "Col2", "Col3"])
```

If you want to add parameter to a query at runtime, you can leave a ? in place of a parameter:

``` python
sql = "INSERT INTO package.TableName (ID, Col1, Col2, Col3) values (?,?,?,?)"

cursor.execute(sql, [1, "Hello", "World", "!"])
```

You can use similar syntax to execute many queries: 

``` python
sql = "INSERT INTO package.TableName (ID, Col1, Col2, Col3) values (?,?,?,?)"

params = [ 
	[1, "Hello", "World", "!"],
    [2, "Foo", "Bar", "Baz"],
    [3, "Alpha", "Beta", "Gamma"],
    [4, "One", "Two", "Three"]
]
cursor.executemany(sql, params)
```
#### SQL alchemy

SQLAlchemy is a Python SQL client which is supported by InterSystems. It can be installed with 

```
pip install "sqlalchemy-iris[intersystems]"
```

This install the InterSystems specific SQLAlchemy driver, as well as the normal SQLAlchemy as a dependency. It is used as follows: 

``` python
from sqlalchemy import create_engine 

# Credentials: 
username = "_system" 
password = "SYS" 
namespace = "USER" 
server = "localhost" 
port = 1972 

DATABASE_URL = f"iris://{username}:{password}@{server}:{port}/{namespace}" 

engine = create_engine(DATABASE_URL, echo=False)
```


You can use this engine to query directly with pandas to create a Pandas DataFrame: 

``` python
import pandas as pd 
query = "SELECT ID, Col1, Col2, Col3 FROM package.TableName"

df = pd.read_sql(query, engine)

df.head()
```

You can also SQLAlchemy to create a table:

``` python
from sqlalchemy import Column, MetaData, Table, select
from sqlalchemy.sql.sqltypes import Integer, VARCHAR
from sqlalchemy_iris import IRISVector

## Create a table, adding column objects to create the schema

demo_table = Table("demoTableName",  ## Give the table a name
                    
                    ## Create metadata for the table
                    MetaData(), 
                    
                    ## Create an ID as the index and autoincrement it
                    Column("ID", Integer, primary_key=True, autoincrement = True),
                    
                    ## Create a column for the item name
                    Column("Name", VARCHAR(1024)),
                    
                    ## Use the special IRIS Vector datatype to embed vectors 
                    Column("EmbeddingVectors", IRISVector(item_type=float, max_items=3)) 
                  )
```

and insert data: 
``` python
with engine.connect() as conn: 
    conn.execute( demo_table.insert(), ## the action being executed
                [
                    {"Name": "Cat","EmbeddingVectors":[4,4,2]},
                    {"Name": "Dog","EmbeddingVectors":[3.5,3.5,2]},
                    {"Name": "Espresso", "EmbeddingVectors":[-2, -2, 1]},
                    {"Name": "Tea", "EmbeddingVectors":[-1, -5, 0]}
                ]
    )
    conn.commit()
```

#### Native connection (globals and methods)

Access globals with an `iris.createIRIS connection:

``` python
## Create connection (as above)
connection = iris.connect(server, port, namespace, username, password)

# Create an iris object
irispy = iris.createIRIS(connection)

# Create a global array in the USER namespace on the server
irispy.set("Value", "myGlobal", "subscript") 

# Read the value from the database and print it
# usage: irispy.get(Global, subscripts1, subscript2, subscript...)

print(irispy.get("myGlobal", "subscript")) # prints "Value"

# Delete the global array and terminate
irispy.kill("myGlobal") 

##close the connection
connection.close()
```

You can also this `irispy` object to used with server-side classes and methods. You call class method using `irispy.classMethodValue` or `irispy.classMethodVoid`, where value and void specify whether anything is returned from the class method. If you need specific return types, you also used `irispy.classMethodString`, or replace `String` with another datatype. 

So we could use the following IRIS class:

```
Class packageName.DemoClass 
{
ClassMethod AddNumbers(a As %Integer, b As %Integer) As %Integer
{
	return a+b	
}
ClassMethod IncrementGlobal(value As %String) As %Status
{
	set ^DemoGlobal($INCREMENT(^DemoGlobal)) = value
}
}
```

With:

```python
# See above for connection
irispy = iris.createIRIS(connection)

number_sum = irispy.classMethodValue("packageName.DemoClass", "AddNumbers", 1, 2) 
print(number_sum) # prints 3

# Sets the first integer subscript of a global to "Hello World"
irispy.classMethodVoid("IncrementGlobal", "Hello World")

print(irispy.get("demoGlobal")) # prints 1 (or the number of times IncrementGlobal has been run)

print(irispy.get("demoGlobal", 1)) # Prints "Hello World"

```

You can also create a class object, for example, say you had the IRIS class: 

```
Class packagename.Person Extends %Persistent
{

	Property Name As %String;
	
	Property Age As %Integer;
	
	Method setName(name As %String) As %Status{
		set ..Name = name
		return
	}
	
	Method addYears(num as %Integer) As %Integer {
		return ..Age + num
	}
}
```

You could use this in an external Python application with: 

```python
# Create new class obeject 
person = irispy.classMethodObject("packagename.Person", "%New")

# Set a property
person.set("Age", 25)
# Get a property
age = person.get("Age")
print(age) # 25

# Call a method without a return with .invokeVoid(methodName, parameter)
person.invokeVoid("setName", "George")
print(person.get("Name")) # prints "George"

# Call a function with a return
new_age = person.invoke("addYears", 5)
print(new_age) # prints 30

# Call the inherited function to save the object to a database
person.invokeVoid("%Save")

```
### Further Reading
- [Orientation for Python Developers | Orientation for Python Developers | InterSystems IRIS Data Platform 2025.2](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GPYDEV_journey)
- [Introduction to the Native SDK for Python | Using the Native SDK for Python | InterSystems IRIS Data Platform 2025.2](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=BPYNAT_about)
