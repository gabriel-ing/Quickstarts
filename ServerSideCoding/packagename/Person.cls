Class packagename.Person Extends %Persistent
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