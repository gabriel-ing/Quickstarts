Class packagename.ClassName Extends %Persistent
{
	Property VariableName As %String [Required]; 
	// A property is a persistent variable.  
	// As %String states that the property is a string
	// Required is a keyword argument. An object cannot be saved without this value
	
	Parameter CONSTANT = 2;
	// A Parameter is a constant
	// Its standard practice to use all caps for parameters
	
	// A Class Method which is called directly from the class
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