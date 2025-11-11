Class sample.StockTable Extends %Persistent
{

Property ProductId As %Integer [ Required ];

Index ID On ProductId [ IdKey ];

Property ProductName As %String;

Property Quantity As %Integer [ Required ];

Property DateLastSold As %DateTime;

ClassMethod CreateNew(pid As %Integer, pName As %String, quantity As %Integer) As %Status
{
        set newItem = ##class(sample.StockTable).%New()
        set newItem.ProductId = pid
        set newItem.ProductName = pName
        set newItem.Quantity = quantity
        set sc = newItem.%Save()
}

Storage Default
{
<Data name="StockTableDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ProductName</Value>
</Value>
<Value name="3">
<Value>Quantity</Value>
</Value>
<Value name="4">
<Value>DateLastSold</Value>
</Value>
</Data>
<DataLocation>^sample.StockTableD</DataLocation>
<DefaultData>StockTableDefaultData</DefaultData>
<ExtentSize>5</ExtentSize>
<IdLocation>^sample.StockTableD</IdLocation>
<IndexLocation>^sample.StockTableI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<OutlierSelectivity>.999999:</OutlierSelectivity>
<Selectivity>0.0001%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="DateLastSold">
<AverageFieldSize>2</AverageFieldSize>
<OutlierSelectivity>.999999:</OutlierSelectivity>
<Selectivity>0.0001%</Selectivity>
</Property>
<Property name="ProductId">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="ProductName">
<AverageFieldSize>11</AverageFieldSize>
<Selectivity>20.0000%</Selectivity>
</Property>
<Property name="Quantity">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>25.0000%</Selectivity>
</Property>
<SQLMap name="ID">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^sample.StockTableS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
