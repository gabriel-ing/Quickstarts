### Embedded Python 

As of 2022, Python can be used in InterSystems IRIS classes with no significant performance cost. To use Embedded Python, simply add the keyword tag `[language=python]` after an InterSystems IRIS method or class method. 

This is generally the most efficient method to use Python with InterSystems IRIS, but you can also connect external applications to InterSystems IRIS, see the [Client-side Python page](../ExternalPython/ExternalPythonQuickstart.md) for more detail.

```python
Class packagename.PythonClass { 

Parameter CONSTANTNAME = 2;

ClassMethod pythonClassMethod(a as %Integer, b as %Integer) [language=python]{ 
	import iris
	
	## Access the constant
	constant = iris.cls(__name__)._GetParameter('CONSTANTNAME')
	
	value = (a+b) * constant
	
	s = f"The result of ' ({a} + {b}) X {constant} ' is {value}"
	print(s)
}
}
```

You could use this function from the ObjectScript terminal like normal: 
```
do ##class(packagename.PythonClass).pythonClassMethod(1,2)
```
This would print: 
```
The result of '(1 + 2) x 2' is 6
```

## Using Classes and Objects

You can use other classes, including instantiating objects, from embedded python using the `iris` package. 

**Please note `import iris` is different in Server-side (embedded) Python and client-side Python through the DB-API or IRIS-native API.**

To use a class method: 

```python
classMethod PythonClassMethodCall(){
	# import iris to access classes
	import iris
	iris.packagename.PythonClass.pythonClassMethod(2, 3)
	# prints ` The result of ' (2 + 3) X 2 ' is 10 `
}
```

To instantiate an object from a class: 

```python
ClassMethod PythonIrisObjects() [language=python]{
	import iris

	# Create new object
	person = iris.packagename.Person._New()
	person.Name = "Jane Doe"
	person.Age = 28
	# Save the object
	person._Save()
}
```

Note, any time objectscript uses a special character in a method, e.g. `%` and `$`, these will be replaced by `_`, for example `.%New()` in ObjectScript becomes `_New()`.

These methods can be used like any other ClassMethod.

#### Using Python Packages

You can install and use Python packages in InterSystems IRIS using the following in the bash terminal:

```
python3 -m pip install --target <installdir>/mgr/python numpy
```

This command installs `numpy` to the InterSystems IRIS install location. For help locating the correct python location, see [Install and Import Python Packages](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GEPYTHON_loadlib).

You can then use `numpy` as you would in regular Python scripts:  

```python
ClassMethod NumpyExample() [ Language = python ]
{
	import numpy as np
	data = np.array([17, 2, 321, 444, 568])
	mean_value = np.mean(data)
	print("Mean:", mean_value) # Prints 270.4
}

```

