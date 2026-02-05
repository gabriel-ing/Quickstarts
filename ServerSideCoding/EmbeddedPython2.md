# Embedded Python

As of InterSystems IRIS 2022.1, Python has been fully integrated into the InterSystems IRIS kernel and can be used with similar performance to ObjectScript. This 'Embedded Python' modality means Python runs locally to the data, reducing the latency cost of transferring the data.

Embedded Python differs from other connection methods (see Connecting Python Applications to IRIS) because the Python kernel is running on the same machine as the data. 

## Pre-requisites

To maximize learning from this guide, it is recommended to test the code provided on your own InterSystems IRIS instance. The easiest way to run an InterSystems IRIS sandbox is to use InterSystems IRIS Community Edition in a docker container, which can be run with the following command. For more information see running IRIS see Get InterSystems IRIS Community with Docker or Get InterSystems IRIS Community Edition with an Install Kit.

```bash
docker run --name my-iris --publish 1972:1972 --publish 52773:52773 -d intersystems/iris-community:latest-em
```

In many places in this guide, there will be references for IRIS classes, many of which you may wish to import onto your IRIS instance. For information on how to do this, see Intro To InterSystems IRIS Classes or Setting Up your Development Environment in VS Code.

### Installing Packages

A major benefit of using Python with InterSystems IRIS is allowing access to the wide ecosystem of Python Libraries available to be installed from PyPI. Packages can be installed with pip, however, they need to be installed to a specific target directory. Standard pip commands will result in an error: `error: externally-managed-environment`. 

To install Python libraries for use in InterSystems IRIS classes, specify the install target with the `--target` flag. The target is the `{IRIS-INSTALL-DIR}/mgr/python`. The following shows the install command for the package `numpy` with the standard install location.  

```bash
pip install --target /usr/irissys/mgr/python numpy 
```

If you are calling into IRIS from Python Files, as described in the `IRIS From Python` section below, you can also create and use virtual environments in the standard way, the details for this are in that section. 

## Modalities

There are several modalities for using Embedded Python with InterSystems IRIS, the choice of which will depend on the use case. Python methods can be called directly from ObjectScript. Alternatively, methods and class methods within python classes can be defined in Python, or Python can be accessed in standalone Python files and connect directly to InterSystems IRIS. You can also write custom SQL functions in Python (this won't be covered in this guide here, for more information see https://docs.intersystems.com/iris20261/csp/docbook/DocBook.UI.Page.cls?KEY=GEPYTHON_runpython#GEPYTHON_runpython_sql) 

For Python-first development, it is recommended to use standalone Python files as this is the only Embedded Python modality that allows a native Python developer environment, including using linters, debuggers and complete error messages. However, other modalities allow easy integration of Python methods into existing workflows, including directly into ObjectScript code.

## Using Python from ObjectScript

Python can be used from ObjectScript, including importing specific Python modules. This modality is best if you have an ObjectScript method, but require functionality which is easier to implement in Python. This uses the class `%SYS.Python` to import the Python module. The following example shows the standard Python Library `base64` being used to decode an encoded string.

```objectscript
// Import base64 Python Library
set base64 =  ##class(%SYS.Python).Import("base64")

set encodedString = "SGVsbG8sIFdvcmxkIQ=="

// Decode the Base64-encoded string using the imported Python module
set decodedString = base64.b64decode(encodedString)

// Write the decoded string
write decodedString
```

~~You can also directly run a Python command with `##class(%SYS.Python).Run()`. You can't return values from this, as the method returns only a boolean success (1) or fail (0), but the Python context is retained within successive calls.~~

```objectscript
do ##class(%SYS.Python).Run("print('Hello World!')") 
// prints Hello World!
do ##class(%SYS.Python).Run("n = 1")
do ##class(%SYS.Python).Run("print(n)")
// prints 1
```

```objectscript
// Import the Python built-ins
set builtins = ##class(%SYS.Python).Import(builtins)

// Create a python list
set mylist = builtins.list()

do mylist.append(1)
do mylist.append(2)
do mylist.append("foo")
do mylist.append("bar")

// Use Python Print
do builtins.print(mylist)

// Outputs: [1, 2, 'foo', 'bar']
```

## Python Within IRIS CLasses

Internal class methods and methods can be written in Python by adding a keyword tag `[language=python]` after a method definition. This method is useful for short methods or integrating methods into existing workflows.

```python
Class packagename.PythonClass Extends %RegisteredObject{ 

Property Name As %String;

Parameter CONSTANTNAME = 2;

ClassMethod pythonClassMethod(a as %Integer, b as %Integer) [language=python]{ 
	import iris
	
	## Access the constant
	constant = iris.cls(__name__)._GetParameter('CONSTANTNAME')
	
	value = (a+b) * constant
	
	s = f"The result of ' ({a} + {b}) X {constant} ' is {value}"
	print(s)
}

Method pythonMethod(pGreeting as %String) [language=python]
{
    # Access Object properties
    print(pGreeting +" "+ self.Name)

    # Access Object Class Methods 
    self.pythonClassMethod(5, 6) 
} 

}
```

The method and class method above is written in Python and can be used in the same way as any other class method, the only thing needed to differentiate it is the `[language=python]` tag. 
To run this from an ObjectScript terminal, use:

```objectscript
do ##class(packagename.PythonClass).PythonClassMethod(1, 2)
set obj = ##class(packagename.PythonClass).%New()

set obj.Name = "John"
do obj.pythonMethod("Hello!")
```

## Calling IRIS from Python Files

Alternatively, Embedded Python can be used in standalone Python files, which can be called from within InterSystems IRIS classes or executed from the terminal in the same way as normal Python files. This method is best for full Python-first development, as it allows standard Python development tools (e.g. linters and debuggers) to be used.

### Setup

Calling into IRIS from Embedded Python requires some environmental set-up to allow access to IRIS from Python. This section will show how this can be done from a bash terminal on the machine running InterSystems IRIS. If you are running InterSystems IRIS in a docker container as recommended, use the following command on your standard terminal (or Powershell if you are running Windows) to start a bash terminal within your docker container.

```bash
docker exec -it my-iris bash
```

If you wish to skip the set-up steps, there is an [Embedded Python Template](https://openexchange.intersystems.com/package/iris-embedded-python-template) available on the developer community which allows you to immediately build and run a docker container with the environment pre-configured, skipping the set up below.

#### Environmental Variables

Before using Embedded Python, certain environmental variables need to be set which may not be set by default. Run the following commands in the terminal to ensure the correct Python kernel is being accessed. This assumes InterSystems IRIS is installed in the default location, if this is incorrect, please change the IRISINSTALLDIR variable before running.

```bash
# Set the IRIS install location. This is the default for docker containers. 
export IRISINSTALLDIR=/usr/irissys/

# Add the binaries to the PATH
export PATH=$PATH:$IRISINSTALLDIR/bin

# Set the default Python to the IRISPYTHON kernel
export PYTHONPATH= $IRISINSTALLDIR/lib/python
```

Along with the install locations, to connect to IRIS from Python, we also need to set the credentials to log in to IRIS. If you are using a Docker container sandbox, you can use the following default Namespace and passwords as follows, otherwise change these commands to your user password.

```bash
# The Namespace to connect to 
export IRISNAMESPACE=USER

# Username
export IRISUSERNAME=SuperUser

# Password
export IRISPASSWORD=SYS
```

These will need to be set in every new terminal instance or login. To make these accessible by default, these can be added to `.bashrc`, which is loaded every time a new terminal is opened. To add them to your `.bashrc`, you can run: 

```bash
cat >> ~/.bashrc << 'EOF'
export IRISINSTALLDIR=/usr/irissys
export PATH="$PATH:$IRISINSTALLDIR/bin"
export PYTHONPATH="$IRISINSTALLDIR/lib/python"
export IRISNAMESPACE=USER
export IRISUSERNAME=SuperUser
export IRISPASSWORD=SYS
EOF

# Load the .bashrc 
source ~/.bashrc
```

### Service Call In

Finally, the service by which Python files call into InterSystems IRIS is called `%Service_CallIn`. This is, by default, disabled in a new InterSystems IRIS instance. Before connecting to InterSystems IRIS from Python (with Embedded Python), this service needs to be enabled. This can either be done from the terminal or the Management Portal. 

To do this from the terminal, first open an IRIS terminal: 

```bash
iris session iris
```

Then run:

```objectscript
// Save the current settings to a new array called `prop`
do ##class(Security.Services).Get("%Service_CallIn",.prop)

// Enable the service
set prop("Enabled")=1

// Allow unauthenticated access (removes the need for environmental credentials)
// set prop("AutheEnabled")=48

// Modify the settings using our edited settings array
do ##class(Security.Services).Modify("%Service_CallIn",.prop)
```

From the Management Portal, you can go to **System Administration -> Security -> Services -> Go**, then select **%Service_CallIn** from the list, click the `Service Enabled` checkbox and press **Save**.

### Using Virtual Environments

As mentioned in the pre-requisites section, global package installs with `pip` need to include a specific target. When running Python files which call into IRIS, you can create an activate a virtual Python environment, which can be used normally. Virtual environments are effective for separating requirements used for specific projects. 

When you've activated a virtual environment (using the correct Python kernel), you can install packages into the environment with standard `pip` installs:

```bash
# Create a virtual environment called .venv in the current directory
python3 -m venv .venv

# Activate the virtual environment
source .venv/bin/activate

#Install packages as normal
pip install numpy
```

### Running Python files 

After the set-up above, Python can be used as standard with either `python3` or `irispython`, including creating a Python shell. One can run files with:

```bash
python3 filename.py
```

You can also run Python files from IRIS classes. To do this, you need to use the Python module `sys` to add the path to the file to the module search path. For example, if we had the following function defined in a file at "/home/irisowner/python_files/hello_world.py": 

```python 
import iris
def main(name):
    print(iris.sql.exec('SELECT "Hello From IRIS-SQL"'))
    print("Hello World from Python")
    return "Hello World from "+name

if __name__=="__main__":
    main("Bash Terminal")
```

We could use this function from either ObjectScript or Python using the following class:

```objectscript
Class sample.RunPythonFile Extends %RegisteredObject
{


ClassMethod RunFromPython() As %Status [ Language = python ]
{
    // Import the Python sys module
    import sys
    
    // Add the path to the file to the module search path  
    sys.path.append("/home/irisowner/python_files")
    
    // Import the file
    import hello_world 

    // Call the main function
    result = hello_world.main("IRIS ClassMethod in Python")
    
    // Print Result
    print(result)
}

ClassMethod RunFromObjectScript() As %Status
{
    // Import the Python sys module
    set sys = ##class(%SYS.Python).Import("sys")
    
    // Add the path to the file to the module search path 
    do sys.path.append("/home/irisowner/python_files")

    // Import the file
    set helloworld = ##class(%SYS.Python).Import("hello_world")

    // Call the main function
    set result = helloworld.main("IRIS ClassMethod in ObjectScript")
    
    // Print Result
    write result,!
    quit $$$OK
}


}
```

These can be run from the IRIS terminal or from ObjectScript with:

``` objectscript
do ##class(sample.RunPythonFile).RunFromObjectScript()
// Output: 
// [['Hello From IRIS-SQL']]
// Hello World from Python
// Hello World IRIS ClassMethod in ObjectScript

do ##class(sample.RunPythonFile).RunFromPython()

// Output: 
// [['Hello From IRIS-SQL']]
// Hello World from Python
// Hello World from IRIS ClassMethod in Python

```



## IRIS Module Reference

The sections above show how to set up and run Python functions with Embedded Python. This section shows how the `iris` module in Embedded Python can be used to perform tasks in IRIS. The code in this section can be used irrespective of which of the above modalities you are using, assuming they are set up correctly.

This is a quick guide to some of the common features of Embedded Python. For a complete reference, see the [InterSystems IRIS Python Module Reference Documentation](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GEPYTHON_reference_core)

### Accessing IRIS Classes

To access internal classes, you simply refer to it using the `iris` import with `iris.package.class`, for example: 

```python
import iris

# Run a class method with:
# iris.PackageName.ClassName.ClassMethodName()

iris.packagename.PythonClass.PythonClassMethod() # The class defined above

print(iris._SYS.System.GetInstanceName()) # Prints "IRIS" or the current instance name
```

The main exception to this simple access syntax is that special characters in a class or method call, e.g. % and % are replaced by an underscore, for example `.%New()` in ObjectScript becomes `_New()` in Python. 

We can see this when instantiating class objects, except the `%` character is replaced as described above: 

```python 
import iris

new_person = iris.sample.Person._New()
new_person.Name = "Jane Doe"
new_person.Age = 28

person._Save()

```
### Running Objectscript

You can run ObjectScript code directly with `iris.execute`

```python
import iris

iris.execute("write 'Hello World from Objectscript'")
iris.execute("set ^demoGlobal(1) = 'foo'")
iris.execute("zwrite ^demoGlobal")

```

### Running SQL

Like in ObjectScript, SQL can be run in "Embedded" style, where the SQL command is executed directly, or Dynamically, where the statement is prepared with placeholders for values, which can be added at runtime. 

Embedded: 

```python
import iris

# Drop table (so file can be re-run)
iris.sql.exec("DROP TABLE IF EXISTS packagename.Person")

# Create table
iris.sql.exec("CREATE TABLE packagename.Person (Name VARCHAR(250), Age INTEGER)")

# Insert Value
iris.sql.exec("INSERT INTO packagename.Person (Name, Age) VALUES ('Jane', 26)")

# Query
rs = iris.sql.exec("SELECT Name, AGE FROM packagename.Person") 

for row in rs:
    print(row)

# Prints:
# ['Jane', 26]

```

Dynamic: 

```python
import iris

# Use ? as a placeholder
query = 'INSERT INTO packagename.Person (Name, Age) VALUES (?, ?)'

# Prepare Query
stmt = iris.sql.prepare(query)

# Define data
people = [("John", 34), ("Amy", 27), ("Peter", 57)]

# Iterate over data
for person in people:

    # Execute statement with data as parameters for the ? placeholders
    stmt.execute(person[0], person[1])    

```

You can also create a pandas dataframe directly from the results
```python
import iris
# Use ? as a placeholder
stmt = iris.sql.prepare("SELECT Name, Age FROM packagename.Person WHERE Age > ?" )

# pass in argument(s) for placeholder
age = 20
rs = stmt.execute(age)
# This will return a Python list of lists, you can iterate as follows:
df = rs.dataframe()
print(df.head())

# Prints
#     name  age
# 0   Jane   26
# 1   John   34
# 2    Amy   27
# 3  Peter   57
```