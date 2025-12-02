## ObjectScript Basics

- ObjectScript is a weakly typed language, meaning the type of variable is not defined in the code. 
- Standard operators are case insensitive while variable names are are case sensitive.
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