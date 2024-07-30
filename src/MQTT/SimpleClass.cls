Class MQTT.SimpleClass Extends (%Persistent, %XML.Adaptor, Ens.Util.RequestBodyMethods)
{

Property topic As %String;

Property seq As %BigInt;

Property myInt As %Library.Integer;

Property myLong As %Library.BigInt;

Property myBool As %Library.Boolean;

Property myDouble As %Library.Double;

Property myFloat As %Library.Float;

Property myBytes As %Library.RawString;

Property myFilename As %Library.String;

Property myString As %Library.String;

Property myArray As %Library.RawString;

Property ReceiveTS As %Library.PosixTime [ InitialExpression = {##class(%Library.PosixTime).CurrentTimeStamp(3)} ];

Index idxseq On seq;

Method %OnNew(topic As %String, seq As %BigInt, myInt As %Integer, myLong As %BigInt, myBool As %Boolean, myDouble As %Double, myFloat As %Float, myFilename As %String, myString As %String, myArray As %RawString) As %Status [ Private, ServerOnly = 1 ]
{
    Set ..topic=topic
    Set ..seq=seq
    Set ..myInt=myInt
    Set ..myLong=myLong
    Set ..myBool=myBool
    Set ..myDouble=myDouble
    Set ..myFloat=myFloat
    Set ..myFilename=myFilename
    Set ..myString=myString
    Set ..myArray=myArray
    Return $$$OK
}

ClassMethod GETNEWID() As %Integer
{
    Quit $INCREMENT(^SIMPLECLASSUNIQ)
}

Storage Default
{
<Data name="SimpleClassDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>topic</Value>
</Value>
<Value name="3">
<Value>seq</Value>
</Value>
<Value name="4">
<Value>myInt</Value>
</Value>
<Value name="5">
<Value>myLong</Value>
</Value>
<Value name="6">
<Value>myBool</Value>
</Value>
<Value name="7">
<Value>myDouble</Value>
</Value>
<Value name="8">
<Value>myFloat</Value>
</Value>
<Value name="9">
<Value>myBytes</Value>
</Value>
<Value name="10">
<Value>myFilename</Value>
</Value>
<Value name="11">
<Value>myString</Value>
</Value>
<Value name="12">
<Value>myArray</Value>
</Value>
<Value name="13">
<Value>ReceiveTS</Value>
</Value>
</Data>
<DataLocation>^MQTT.SimpleClassD</DataLocation>
<DefaultData>SimpleClassDefaultData</DefaultData>
<IdLocation>^MQTT.SimpleClassD</IdLocation>
<IndexLocation>^MQTT.SimpleClassI</IndexLocation>
<StreamLocation>^MQTT.SimpleClassS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
