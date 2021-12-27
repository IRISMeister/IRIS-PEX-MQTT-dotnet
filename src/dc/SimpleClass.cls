Class dc.SimpleClass Extends %Library.PersistentXEP [ Final, GeneratedBy = %FOI.Schema, ProcedureBlock ]
{

Parameter IMPORTTIMESTAMP = "12/17/2021 05:09:29";

Parameter IMPORTFLAGS = 1;

Property "<myInt>k__BackingField" As %Library.Integer;

Property "<myLong>k__BackingField" As %Library.BigInt;

Property "<myBool>k__BackingField" As %Library.Boolean;

Property "<myDouble>k__BackingField" As %Library.Double;

Property "<myFloat>k__BackingField" As %Library.Float;

Property "<myBytes>k__BackingField" As %Library.RawString;

Property "<myString>k__BackingField" As %Library.String;

Property "<myArray>k__BackingField" As list Of %Library.RawString(STORAGEDEFAULT = "list");

Property "<myMap>k__BackingField" As array Of %Library.String(STORAGEDEFAULT = "list");

Index idx1 On "<myLong>k__BackingField" [ Type = index ];

Storage Default
{
<Data name="SimpleClassDefaultData">
<Value name="1">
<Value>
<![CDATA[<myInt>k__BackingField]]></Value>
</Value>
<Value name="2">
<Value>
<![CDATA[<myLong>k__BackingField]]></Value>
</Value>
<Value name="3">
<Value>
<![CDATA[<myBool>k__BackingField]]></Value>
</Value>
<Value name="4">
<Value>
<![CDATA[<myDouble>k__BackingField]]></Value>
</Value>
<Value name="5">
<Value>
<![CDATA[<myFloat>k__BackingField]]></Value>
</Value>
<Value name="6">
<Value>
<![CDATA[<myBytes>k__BackingField]]></Value>
</Value>
<Value name="7">
<Value>
<![CDATA[<myString>k__BackingField]]></Value>
</Value>
<Value name="8">
<Value>
<![CDATA[<myArray>k__BackingField]]></Value>
</Value>
<Value name="9">
<Value>
<![CDATA[<myMap>k__BackingField]]></Value>
</Value>
</Data>
<DataLocation>^Cj7V.Bcqj.1</DataLocation>
<DefaultData>SimpleClassDefaultData</DefaultData>
<ExtentLocation>^Cj7V.Bcqj</ExtentLocation>
<IdLocation>^Cj7V.Bcqj.1</IdLocation>
<Index name="IDKEY">
<Location>^Cj7V.Bcqj.1</Location>
</Index>
<Index name="idx1">
<Location>^Cj7V.Bcqj.2</Location>
</Index>
<IndexLocation>^Cj7V.Bcqj.I</IndexLocation>
<StreamLocation>^Cj7V.Bcqj.S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
