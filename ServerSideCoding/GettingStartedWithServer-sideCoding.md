# Getting Started with Server-Side Code

A major benefit of the InterSystems IRIS, the core data platform behind the other InterSystems products, is its ability to run code in the same location, or on the same server, as the databases. This ability allows operations involving the data, to be run directly on the data, without having to move or copy the data. As a result, InterSystems IRIS is a market leader in speed of processing. As a result, InterSystems IRIS, and the technology built with it,  enables rapid data processes, real-time analytics, faster machine learning and many more great features. 

InterSystems IRIS runs on Object-oriented code within Classes. The functions within the classes are called methods and are written in Embedded languages - ObjectScript and Python. 

This guide is meant to be a one-stop reference guide to IRIS classes and coding with ObjectScript and embedded Python for experienced developers. For comprehensive documentation, see the relevant sectons of documentation: 
- [Basic Ideas in Class Programming](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GOBJ_intro)
- [Introduction to ObjectScript](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GCOS_intro)
- [Introduction to Embedded Python](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=AFL_epython)

## ObjectScript Basics

- ObjectScript is a weakly typed language, meaning the type of variable is not defined in the code. 
- Standard operators are not case sensitive, variable names are all case sensitive.
- `//` denotes a comment, ``/*  */`` denotes multi-line comments. 

```cpp
// Setting a variable 
set output = "Hello World!"
set n = 1

// Printing a variable to the terminal
write output 

// Run a class method
do ##class(packagename.ClassName).MethodName()


// Lists
set mylist = $LISTBUILD("Apple", "Orange", "Pear")

// Accessing list items
write $LIST(mylist, 2) //prints "Orange" (index starts at 1)

// Arrays 
set myarray(1) = "Hello"
set myarray(2) = "World"
set myarray("Foo") = "bar"

// Accessing array items
write myarray(1), myarray(2) //prints "HelloWorld" 

// Writing Arrays
zwrite myarray 
/*Output: 
	myarray(1)="Hello"
	myarray(2)="World"
	myarray("Foo")="bar" 
*/

// basic conditional
if (n = 1){
	write "One"
} elseif (n = 2){
	write "Two"
}

// Inline conditional
// <command>:<condition> variable

write:n=1 "One" // Prints "One" because n=1
write:n=2 "Two" // Does not write anything as conditional not fulfilled


//Basic For loop
// iterator = 
for i=1: 1: 10 {
	write i 
}
```
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
	// Its standard practice to use all caps for parameters
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


### Globals

Globals are the storage structure at the heart of InterSystems IRIS. These are hierarchical multi-dimensional arrays where each node of the hierarchical tree structure has a key, or subscript and a value. Globals are denoted by a caret `^`, e.g. `^GlobalName`.

Nodes can be referenced, or values set by listing out the subscripts, so `^GlobalName(sub1, sub2, ...)`

```
set ^Demo(1,2,"position") = 4
set ^Demo(1) = "Hello"
set ^Demo(5) = "World"
```

Would create the following global: 

```
          ^Demo
        /       \
      /          5 : "World"
	1 : "Hello"
	|
	2 :
	|
position: 4
```

Subscripts and values can be any type. If you create a SQL table in InterSystems IRIS, it will be stored as a global, with each row being stored under a different index ID.

For a detailed explaination of globals, see: [Video: What Are Globals? | Youtube](https://www.youtube.com/watch?v=jJifoZq2bW0)


### Embedded Python 

As of 2022, Python can be used in InterSystems IRIS classes with no significant performance cost. To use Embedded Python, simply add the keyword tag `[language=python]` after an InterSystems IRIS method or class method. For example: 

While this is generally the most effective method to use Python with InterSystems IRIS, you can also connect external applications to InterSystems IRIS, see the external language page for more detail (**Add link to external language quickstart**).

```python
Class packagename.PythonClass { 

PARAMETER CONSTANTNAME = 2;

ClassMethod pythonClassMethod(a as %Integer, b as %Integer) [language=python]{ 
	import iris
	
	## Access the constant
	constant = iris.cls(__name__)._GetParameter('CONSTANTNAME')
	
	value = (a+b) * constant
	
	s = f"The Sum of {a} and  {b} times {constant} equals {value}"
	print(s)
	return value
}
}
```

You can use IRIS classes by importing IRIS: 

```python
ClassMethod PythonIrisObjects() [language=python]{
	# import iris to access classes
	import iris
	# Create new object
	person = iris.packagename.Person._New()
	person.Name = "name"
	# Save the object
	person._Save()
}
```

Note, any time objectscript uses a special character in a method, e.g. `%` and `$`, python will  replace these with underscores `_`

These methods can be used like any other class method: 

```
set value = ##class(packagename.PythonClass).PythonClassMethod(1, 2)
- The Sum of 1 and 2 times 2 equals 6

write value
- 6  

do ##class(packagename.PythonClass).PythonIrisObjects()
// Saves a new person to database (person global)
```

#### Using Python Packages

You can install and use Python packages in InterSystems IRIS using the following in the bash terminal:

```
python3 -m pip install --target <installdir>/mgr/python numpy
```

Installs `numpy` to the InterSystems IRIS install location. For help locating the correct python location, see  [Install and Import Python Packages](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GEPYTHON_loadlib).

You can then use `numpy` as you would in regular Python scripts:  
```python
ClassMethod NumpyExample() [langauge=python]
{
	import numpy as np
	data = np.array([1, 2, 3, 4, 5])
	mean_value = np.mean(data)
	print("Mean:", mean_value)
	
}
```

