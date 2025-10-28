Class packagename.DemoClass
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
