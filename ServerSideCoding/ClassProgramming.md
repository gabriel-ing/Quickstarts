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
			if (i = 3) {
				write !, "Fizz"
			} elseif (i = 5){
				write !, "Buzz"
			} else{ 
				// .. denotes a property or method of the parent class
				write !, ..VariableName
			}
		}
	}
}
```


You can call a ClassMethod without instantiating a class, using the do operator to run a method and  `##class()` to reference a class.

```
do ##class(packagename.ClassName).AddNums(5, 6)

- The sum of 5 and 6 is 11
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
write object.FizzBuzz(1, 2)
```

Print the following:
```
1
Hello World // (Variable name set above)
3
Fizz
5
Buzz
```


### Persistent classes 

A `%Persistent` class is a class that can be saved directly into the database. They can be used in the following way:

```
set person = ##class(packageName.Person).%New()
set person.Name = "John"
set person.Age = 25
do person.%Save() 
```
