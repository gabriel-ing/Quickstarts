### Embedded Python 

As of 2022, Python can be used in InterSystems IRIS classes with no significant performance cost. To use Embedded Python, simply add the keyword tag `[language=python]` after an InterSystems IRIS method or class method. 

This is generally the most efficient method to use Python with InterSystems IRIS, but you can also connect external applications to InterSystems IRIS, see the [Client-side Python page](../ExternalPython/ExternalPythonQuickstart.md) for more detail.

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

This command installs `numpy` to the InterSystems IRIS install location. For help locating the correct python location, see  [Install and Import Python Packages](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GEPYTHON_loadlib).

You can then use `numpy` as you would in regular Python scripts:  
```python
ClassMethod NumpyExample() [language=python]
{
	import numpy as np
	data = np.array([1, 2, 3, 4, 5])
	mean_value = np.mean(data)
	print("Mean:", mean_value)
	
}
```

