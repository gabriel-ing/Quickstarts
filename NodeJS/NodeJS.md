# Connecting to InterSystems IRIS With Node.js 

JavaScript and TypeScript backends running on Node.js can connect to InterSystems IRIS using several available tools. The official InterSystems IRIS native SDK is [@intersystems/intersystems-iris-native](https://www.npmjs.com/package/@intersystems/intersystems-iris-native?activeTab=readme). 

This package can be installed using node package manager (npm) with: 

```
npm i @intersystems/intersystems-iris-native
```

After this, the driver can be used as follows: 

```js
// Import the irisnative package
import * as irisnative from "@intersystems/intersystems-iris-native"


// Create the connection
const connection = irisnative.createConnection({
    host:'localhost', // server
    port:1972, // Port
    ns:'USER', // Namespace
    user:'SuperUser', // Username
    pwd:'SYS' // Password
  })

// Create irisjs object
const irisjs = connection.createIris()

console.log("connection made")

// Set a global ( ^test(1) = "hello world!" )
irisjs.set('hello world!','test',1)

// Get a global 
console.log(iris.get('test',1))

// Close the connection
connection.close()
```


## Native connection (globals and methods)


You can use this `irisjs` object to used with server-side classes and methods. You call class method using `irisjs.classMethodValue` or `irisjs.classMethodVoid`, where value and void specify whether anything is returned from the class method.

If you need specific return types, you also used `irispy.classMethodString`, or replace `String` with another datatype. 

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

```
Class sample.Person Extends %Persistent
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

You could use this from a node application with: 

```js
// Create an instance of the Person class
const person = irisjs.classMethodObject("sample.Person", "%New")

// Set property with .set(property, value)
person.set("Age", 25)

// Get property with .get(property)
console.log(`Person's age is ${person.get("Age")}`) // Prints "Person's age is 25"

// Call method without returning a vaule with .invokeVoid(methodName, arg1, arg2, ...)
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

- [mg-dbx](https://github.com/chrisemunt/mg-dbx)/ [mg-dbx-napi](https://github.com/chrisemunt/mg-dbx-napi) by MGateway Ltd and Chris Munt

