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

}
