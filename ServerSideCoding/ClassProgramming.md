## Classes

The code used in InterSystems IRIS is organised in classes (file extension `.cls`). 

Classes have components, such as properties, parameters, methods and class methods. Classes can contain many different languages including InterSystems ObjectScript, Embedded Python, SQL and XML. 

Many features of classes and ObjectScript are demonstrated in the example class below:

``` cpp
/* Class definition
packagename is the directory containing the .cls file
*/
Class packagename.ClassName Extends %Persistent
{
	// A property is a persistent variable.  
	// As %String states that the property is a string
	// Required is a keyword argument, meaning the object cannot be saved without this variable
	Property VariableName As %String [Required]; 

	// A Parameter is a constant
	// It's standard practice to use all caps for parameters
	Parameter CONSTANT = 2;
	
	// A Class Method is called directly from the class, without needing to be instantiated
	// Takes two integers in, returns a string out
	ClassMethod AddNums(param1 As %Integer, param2 As %Integer) As %String
	{
		// Set operator assigns the value 
		set sum = param1 + param2 
		
		// Use _ operator to join strings
		set output = "The sum of "_param1_" and "_param2_" is "_sum
		return output
	}
	
	// A Method is called from an instantiated object from the class
	Method FizzBuzz(max As %Integer)
	{
		// Loop with  iterator=start : step : Maximum
		// ..# refers to a Parameter of the parent class
		for i=1 : ..#CONSTANT : max
		{			
			// WRITE operator outputs result to terminal
			// ! operator creates a new line
			write !, i
			
			// Basic Conditional Format
			// # is modulo operator (remainder)
			if (i # 3 = 0) && (i # 5 = 0) {
				write "  FizzBuzz"
			} 
			elseif (i # 3 = 0){
				write "  Fizz"
			} 
			elseif (i # 5 = 0){
				write "  Buzz"
			}
			else{ 
				// .. denotes a property or method of the parent class
				write "  "_..VariableName
			}
		}
	}
}
```


You can call a ClassMethod without instantiating a class, using the do operator to run a method and  `##class()` to reference a class.

```
do ##class(packagename.ClassName).AddNums(1, 2)

- The sum of 1 and 2 is 3
```

You can instantiate a persistent object with;

```
set object = ##class(packagename.ClassName).%New()
```

To use properties: 

```
set object.VariableName = "Hello World"
write object.VariableName // prints Hello World to terminal
```

A method can be used from an object:

```
write object.FizzBuzz(15)
```
This outputs the following:
```
1  Hello World 
3  Fizz
5  Buzz
7  Hello World
9  Fizz
11  Hello World
13  Hello World
15  FizzBuzz
```
This function uses the `CONSTANT` parameter as a step size, the `#` modulo operator to calculate a remainder, which is used for the conditional, and the `VariableName` property which was set above to output `Hello World`.


### Persistent classes 

A `%Persistent` class is a class that can be saved directly into the database. Properties of a persistent class are projected into columns of a relational table, which can then be queried with SQL. A persistent class is created by extending (inheriting from) the `%Persistent` superclass. Persistent classes can also have methods, class methods, parameters or other class components. 

```
Class packagename.Person Extends %Persistent{

	// Person's Name
	// As %String defines the data-type
	Property Name As %String;  
	
	// Person's Age (in Years)
	Property Age As %Integer; 
}
```

Persistent classes can be accessed as objects as follows: 
```
set person = ##class(packagename.Person).%New()
set person.Name = "John Smith"
set person.Age = 25
do person.%Save()
```
Persistent classes are automatically given an ID upon saving. We can access the entry at a specific ID using `%OpenId`
```
set person2 = ##class(packagename.Person).%OpenId(2)
write person2.Name // Outputs the name of the person with ID 2
```

### Persistent classes in SQL 

A Persistent class can then be queried using SQL. 

There are a number of methods for calling SQL, on the database, which are detailed in other tutorials, for example a query can be run from client-side applications connected through ODBC, JDBC or Python DB-API, from the Management Portal SQL explorer or server-side code. 

```sql
SELECT Name, Age FROM packagename.Person 
```

This would return the following table: 

|Name|Age|
|-----------|----|
| John Smith| 25 |


