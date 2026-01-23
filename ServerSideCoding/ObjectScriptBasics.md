# ObjectScript Basics

- ObjectScript is a weakly typed language, meaning the type of variable is not defined in the code. 
- Standard operators are case insensitive while variable names are are case sensitive.
- `//` denotes a comment, ``/*  */`` denotes multi-line comments. 
- ObjectScript is compiled into code 

Below is a quick guide to the most basic features of the language.

## Setting Variables

Variables are defined and set with the `set` command:

```objectscript
set output = "Hello World!"
set n = 1
```

## Writing Variables

Variables are written with `write`:

```objectscript
write output // writes "Hello World!" to terminal
write output, n //writes "Hello World!1 to Terminal
```

`write` doesn't add blank spaces or line-breaks. To add a line break, the ! is used:

```objectscript
write output, !, n
// Writes: 
// Hello World! 
// 1
```

The `_` operator can be used to concatenate values:

```objectscript
write output_" "_n // writes "Hello World! 1"
```

## Running functions and methods

To run functions, the `do` command is used. For a function stored within a class method, we access the class with `##class(packagename.ClassName)`:

```objectscript
// Run a class method
do ##class(packagename.ClassName).MethodName()
```

Note, this command will fail as the Class and Method have not been defined. For more information on classes, methods and class methods, see the [Intro to InterSystems IRIS Classes]().

## Lists and Arrays 

To create and access list items, you can use the `$LISTBUILD` and `$LIST` functions:
```objectscript
// Lists
set mylist = $LISTBUILD("Apple", "Orange", "Pear")

// Accessing list items
write $LIST(mylist, 2) //prints "Orange" (index starts at 1)
```

Arrays on the other hand, are stores of key-value pairs. The keys can be integers or strings:

```objectscript
// Arrays 
set myarray(1) = "Hello"
set myarray(2) = "World"
set myarray("Foo") = "bar"

// Accessing array items
write myarray(1), myarray(2) //prints "HelloWorld" 

write myarray("Foo") // prints Bar

```

The entire content of arrays (and several other data structures) can be written with `zwrite`

```objectscript
// Writing Arrays
zwrite myarray 
/*Output: 
	myarray(1)="Hello"
	myarray(2)="World"
	myarray("Foo")="bar" 
*/
```

## Conditionals

The syntax for conditionals is as follows: 

```objectscript
// basic conditional
if (n = 1){
	write "One"
} elseif (n = 2){
	write "Two"
} else {
	write "Not One or Two"
}
```

Conditionals can also be added to other commands, using inline conditionals. These take the form of `{command}:{conditional} {Parameter if condition is true}`

```objectscript
set n=1

write:n=1 "One" // Prints "One" because n=1
write:n=2 "Two" // Does not write anything as conditional not fulfilled

do:n=2 ##class(packagename.ClassName).MethodName() // doesn't run because n!=2
```

## Loops

### for loop

The basic for loop syntax is as follows:

```objectscript
//Basic For loop
// for iterator : step : maximum{ ... }
for i=1: 1: 10 {
	// ! is the new line operator
	write i , ! 
	
} // Outputs the numbers between 1-10 (inclusive) on new lines
```

### While Loop

And the basic while loop is as follows: 

```objectscript
set x=1
while x<10 {
	write x, !
	set x = x+1
} 

// Outputs numbers 1-9 on new lines
```

If you want the loop to execute once before evalutating the expression, you can use `do...while`L 

```objectscript
set x=1
do {
	write x, !
	set x=x+1
} while x<2

// Outputs 1, then loop ends
```

## Try...Catch

You can catch exceptions using try, catch blocks:

```objectscript
set newarray(1) = 1
try{
	write newarray(2)
}
catch{
	write "Code Errored - maybe we haven't defined newarray(2)", !
	write "The Error Message is "_$ZERROR,!
}

// Running this (as a method/class method) would output:
// Code Errored - maybe we haven't defined newarray(2)
// The Error Message is <UNDEFINED>MethodName+3^packagename.ClassName.1 *newarray(2)
```

## Case insensitivity and shorthand

Objectscript commands are case insensitive and are compiled into shorthand. Therefore the following commands are all equivalent: 

```objectscript
set n = 1
SET n = 1
SeT n = 1
S n=1 
s n=1
```

Note this doesn't apply to variables, so attempting to access `N` would give an `UNDEFINED` error.

Some other examples of this are shown below:
```objectscript
w n // Shorthand for Write

set mylist = $LB("1", "2") // Shorthand for $listbuild

zw newarray // Shorthand for Zwrite

d ##class(packagename.ClassName).MethodName() // Shorthand for Do
```
