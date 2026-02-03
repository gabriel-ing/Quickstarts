# Connecting to InterSystems IRIS With Node.js 

JavaScript and TypeScript backends running on Node.js can connect to InterSystems IRIS using several available tools. The official InterSystems IRIS native SDK is [@intersystems/intersystems-iris-native](https://www.npmjs.com/package/@intersystems/intersystems-iris-native?activeTab=readme). 


## Set-up

To use the Node.js SDK, first install Node.js. Then, start a new project with:

```
npm init -y 
```

The `-y` flag skips interactive questions about the project, including name (it will take the directory name), version, description, etc. 

Then install the InterSystems IRIS SDK with:

```
npm install @intersystems/intersystems-iris-native
```

To use the package, you can either use ES Module syntax (`import`), or commonjs syntax (`require`). The npm default is the commonjs syntax. For this use:

```js
const irisnative = require("@intersystems/intersystems-iris-native");
```

To use ES Module syntax, change open the `package.json` file in your directory, change the type value to the following:

```json
	"type":"module", 
```

With ES Module syntax, you can import the package with: 

```js
import * as irisnative from "@intersystems/intersystems-iris-native";
```


## Connection

To connect to an instance of InterSystems IRIS, first ensure the instance is running. You will need the standard connection credentials of server (or host), superserver port (default is 1972), namespace, username and password. The example below shows the connection to an instance of InterSystems IRIS community running locally.

```js
// Import the irisnative package
import * as irisnative from "@intersystems/intersystems-iris-native";

// Create the connection
const connection = irisnative.createConnection({
    host:'localhost', // Server
    port:1972, // Port
    ns:'USER', // Namespace
    user:'SuperUser', // Username
    pwd:'SYS' // Password
  })

if (connection){
    console.log("Connection Made!")
}

// Close the connection
connection.close()
```

To use this example, save the code into a file, `demo.js`. Then run the file with:

```sh
node ./demo.js
```

## Accessing Globals

To access globals, create an `irisjs` object using `connection.createIris()`. Then use standard `.set` and `.get` methods.

```js
// Create irisjs object
const irisjs = connection.createIris()


// Set a Global 
// Syntax : irisjs.set("Value", "GlobalName", "subscript1", "subscript2" )

irisjs.set('Hello World!','Test',1) // Equivalent to: Set ^Test(1) = "Hello World!"


// Get a global 
// Syntax: irisjs.get("GlobalName", "subscript1", "subscript2" )

const globalValue = irisjs.get('Test',1) // Accessing ^Test(1) 

console.log(globalValue) // Outputs "Hello World!"
```

To test this snippet, copy it into the `demo.js` file above, **before** the connection.close() call. Then run the file again with `node ./demo.js`.

## Calling IRIS Methods

The `irisjs` object can also use IRIS methods and classes. To call class method use `irisjs.classMethodValue` or `irisjs.classMethodVoid`, where value and void specify whether anything is returned from the class method. If you need specific return types, you also used `irispy.classMethodString`, or replace `String` with another datatype.

For example, if we had the following class in our instance of InterSystems IRIS (for information on how to load this into your instance, see [Set-up your development environment in VSCode](link).

```objectscript
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

We could use the following code to access the Class Methods:

```js
// See above for connection
const irisjs = connection.createIris()
console.log(irisjs)

const number_sum = irisjs.classMethodNumber("sample.DemoClass", "AddNumbers", 1, 2) 
console.log(`The sum of 1 and 2 is ${number_sum}`) // prints "The sum of 1 and 2 is 3"

// Sets the first integer subscript of a global to "Hello World"
irisjs.classMethodVoid("sample.DemoClass", "IncrementGlobal", "Hello World")

console.log(irisjs.get("DemoGlobal")) // Prints 1 (or the number of times IncrementGlobal has been run)

console.log(irisjs.get("DemoGlobal", 1)) // Prints "Hello World"

```

You can also create a class object, for example, say you had the IRIS class:

```objectscript
Class sample.Person Extends %Persistent
{

    Property Name As %String;
    
    Property Age As %Integer;
    
    Method setName(name As %String) As %Status{
        set ..Name = name
    }
    
    Method addYears(num as %Integer) As %Integer {
        return ..Age + num
    }
}
```

You could use this from a node application with: 

```js
// Create an instance of the Person class
const person = irisjs.classMethodObject("sample.Person", "%New")

// Set property with .set(property, value)
person.set("Age", 25)

// Get property with .get(property)
console.log(`Person's age is ${person.get("Age")}`) // Prints "Person's age is 25"

// Call method without returning a value with .invokeVoid(methodName, arg1, arg2, ...)
person.invokeVoid("setName", "Alison Turner")

console.log(`Person's name is ${person.get("Name")}`) // Prints "Person's name is Alison Turner"

// Call method with return value with .invoke(methodName, arg1, arg2, ...)
const new_age = person.invoke("addYears", 5)
console.log(`New age is ${new_age}`) // Prints "New age is 30

// Save the object by invoking the %Save method
person.invokeVoid("%Save")
```

## Community libraries

There are several community libraries that can integrate with InterSystems IRIS, providing different experiences which may improve the efficiency of certain functions. **Please note, these are not officially supported by InterSystems, so use at your own risk**

- [TypeORM-IRIS](https://openexchange.intersystems.com/package/typeorm-iris) By Dmitry Maslennikov
    This library connects to InterSystems IRIS using a the Type-ORM framework, allowing better access to databases in with SQL. 

- [mg-dbx](https://github.com/chrisemunt/mg-dbx)/[mg-dbx-napi](https://github.com/chrisemunt/mg-dbx-napi) by MGateway Ltd and Chris Munt

