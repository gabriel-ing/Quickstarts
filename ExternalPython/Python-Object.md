## Native connection (globals and methods)

Globals and InterSystems IRIS classes can be accessed using an `iris.createIRIS` connection:

``` python
import iris

server = "localhost"
port = 1972 
namespace = "USER"
username = "_system"
password = "SYS"

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

You can also use the irispy object with server-side classes and methods. You call class method using `irispy.classMethodValue` or `irispy.classMethodVoid`, where value and void specify whether anything is returned from the class method. If you need specific return types, you also used `irispy.classMethodString`, or replace `String` with another datatype. 

So we could use the following IRIS class:

```
Class sample.DemoClass 
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

number_sum = irispy.classMethodValue("sample.DemoClass", "AddNumbers", 1, 2) 
print(number_sum) # prints 3

# Sets the first integer subscript of a global to "Hello World"
irispy.classMethodVoid("sample.DemoClass", "IncrementGlobal", "Hello World")

print(irispy.get("DemoGlobal")) # prints 1 (or the number of times IncrementGlobal has been run)

print(irispy.get("DemoGlobal", 1)) # Prints "Hello World"

```

You can also create a class object, for example, say you had the IRIS class: 

```
Class sample.Person Extends %Persistent
{

	Property Name As %String;
	
	Property Age As %Integer;
	
	Method setName(name As %String) As %Status{
		set ..Name = name
		quit $$$OK
	}
	
	Method addYears(num as %Integer) As %Integer {
		return ..Age + num
	}
}
```

You could use this in an external Python application with: 

```python
# Create new class object 
person = irispy.classMethodObject("sample.Person", "%New")

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