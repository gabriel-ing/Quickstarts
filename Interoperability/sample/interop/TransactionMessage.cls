Class sample.interop.TransactionMessage Extends (%Persistent, Ens.Request, %XML.Adaptor)
{

Property OrderId As %Integer;

Property DateTime As %String;

Property ProductId As %Integer;

Property ProductName As %String;

Property Quantity As %Integer;

Storage Default
{
<Data name="TransactionMessageDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>OrderId</Value>
</Value>
<Value name="3">
<Value>DateTime</Value>
</Value>
<Value name="4">
<Value>ProductId</Value>
</Value>
<Value name="5">
<Value>ProductName</Value>
</Value>
<Value name="6">
<Value>Quantity</Value>
</Value>
</Data>
<DataLocation>^sample.inte732.Transaction5494D</DataLocation>
<DefaultData>TransactionMessageDefaultData</DefaultData>
<IdLocation>^sample.inte732.Transaction5494D</IdLocation>
<IndexLocation>^sample.inte732.Transaction5494I</IndexLocation>
<StreamLocation>^sample.inte732.Transaction5494S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
