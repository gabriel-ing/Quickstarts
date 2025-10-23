Class petapi.Pet Extends (%Persistent, %JSON.Adaptor)
{

// ID value 

Property PetId As %Integer;

// Make Pet Id the primary key

Index PetIDX On PetId [ IdKey ];

// Name of Pet

Property Name As %String;

// Type of animal

Property Type As %String;

Storage Default
{
<Data name="PetDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>Type</Value>
</Value>
</Data>
<DataLocation>^petapi.PetD</DataLocation>
<DefaultData>PetDefaultData</DefaultData>
<IdLocation>^petapi.PetD</IdLocation>
<IndexLocation>^petapi.PetI</IndexLocation>
<StreamLocation>^petapi.PetS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
