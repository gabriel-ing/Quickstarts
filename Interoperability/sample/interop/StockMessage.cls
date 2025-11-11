Class sample.interop.StockMessage Extends (%Persistent, Ens.Response, %XML.Adaptor)
{

Property ProductId As %Integer;

Property ProductName As %String;

Property CurrentStock As %Integer;

Storage Default
{
<Data name="StockMessageDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ProductId</Value>
</Value>
<Value name="3">
<Value>ProductName</Value>
</Value>
<Value name="4">
<Value>CurrentStock</Value>
</Value>
</Data>
<DataLocation>^sample.interop.StockMessageD</DataLocation>
<DefaultData>StockMessageDefaultData</DefaultData>
<IdLocation>^sample.interop.StockMessageD</IdLocation>
<IndexLocation>^sample.interop.StockMessageI</IndexLocation>
<StreamLocation>^sample.interop.StockMessageS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
