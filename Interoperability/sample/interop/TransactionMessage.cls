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
<ExtentSize>117</ExtentSize>
<IdLocation>^sample.inte732.Transaction5494D</IdLocation>
<IndexLocation>^sample.inte732.Transaction5494I</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,16,$lb("-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000"),$lb(21,21,21,21,21,21,21,21,21,21,21,21,21,21,21),$lb(758198320,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,758198320))</Histogram>
<OutlierSelectivity>.999999:</OutlierSelectivity>
<Selectivity>0.0001%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,1,0,$lb(1,8,16,24,32,40,48,56,64,72,80,88,96,103,110,117),$lb(0,0,0,0,0,1,0,0,0,0,1,0,0,1,2),"")</Histogram>
<Selectivity>1</Selectivity>
</Property>
<Property name="DateTime">
<AverageFieldSize>15.8</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,0,$lb(" "," "," "," "," "," 2025-11-11 16:27:59"," 2025-11-11 16:49:01"," 2025-11-11 17:02:03"," 2025-11-11 17:17:10"," 2025-11-12 09:12:51"," 2025-11-12 09:24:14"," 2025-11-12 09:59:21"," 2025-11-13 13:31:30"," 2025-11-13 13:39:12"," 2025-11-13 15:05:21"," 2025-11-14 13:18:40"),$lb(2,2,2,2,1,15,13,15,10,15,15,10,16,13,10),$lb(536870912,0,0,0,0,0,0,0,0,0,842019381,842480181,876165680,909784121,926560306,808598064,825702961,824193335,840970297,825375285,842283569,842283569,892942898,840970297,857747763,825897776,960114994,859452217,893005877,857747765,874524979,540160050))</Histogram>
<OutlierSelectivity>.273504:</OutlierSelectivity>
<Selectivity>1.5793%</Selectivity>
</Property>
<Property name="OrderId">
<AverageFieldSize>2.73</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,1,5,$lb(-10000000000000000000,-10000000000000000000,-10000000000000000000,-10000000000000000000,-10000000000000000000,7,15,19,23,27,31,35,40,43,47,50),$lb(21,21,21,21,0,0,1,0,1,0,1,0,1,1,0),"")</Histogram>
<OutlierSelectivity>.273504:</OutlierSelectivity>
<Selectivity>1.5793%</Selectivity>
</Property>
<Property name="ProductId">
<AverageFieldSize>3.01</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,1,0,$lb(101,102,102,102,102,102,102,103,104,104,104,104,104,104,104,1000),$lb(2,3,3,3,3,3,2,2,3,3,3,3,3,3,2),"")</Histogram>
<Selectivity>20.0000%</Selectivity>
</Property>
<Property name="ProductName">
<AverageFieldSize>11.27</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,0,$lb("  DESKTOP PC","  DESKTOP PC","  DESKTOP PC","  DESKTOP PC","  DESKTOP PC","  DESKTOP PC","  DESKTOP PC","  LAPTOP","  MONITOR","  MONITOR","  MONITOR","  MONITOR","  MONITOR","  MONITOR","  MONITOR"," TEST NAME"),$lb(13,13,13,13,13,13,2,2,10,10,10,10,10,10,1),$lb(538985541,0,0,0,0,0,0,0,0,0,0,0,0,1145393995,1279348820,1279348820,1297043017,0,0,0,0,0,0,0,0,0,0,0,0,541937486,1413829460,542393683))</Histogram>
<Selectivity>20.0000%</Selectivity>
</Property>
<Property name="Quantity">
<AverageFieldSize>2.9</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,1,0,$lb(-97,-43,-19,-7,0,1,3,4,4,4,4,9,9,9,9,9),$lb(1,1,1,0,0,0,0,1,1,1,0,1,1,1,1),"")</Histogram>
<OutlierSelectivity>.299145:9</OutlierSelectivity>
<Selectivity>2.6956%</Selectivity>
</Property>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^sample.inte732.Transaction5494S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
