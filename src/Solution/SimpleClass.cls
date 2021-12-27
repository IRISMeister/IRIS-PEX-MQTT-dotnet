Class Solution.SimpleClass Extends (%Persistent, %XML.Adaptor, Ens.Util.RequestBodyMethods)
{

Property topic As %String;

Property seq As %BigInt;

Property myInt As %Library.Integer;

Property myLong As %Library.BigInt;

Property myBool As %Library.Boolean;

Property myDouble As %Library.Double;

Property myFloat As %Library.Float;

Property myBytes As %Library.RawString;

Property myString As %Library.String;

// a list of binary array
Property myArray As list Of %Library.RawString(STORAGEDEFAULT = "list");

// not using this.
Property myMap As array Of %Library.String(STORAGEDEFAULT = "list");

Index idxseq On seq;

Method %OnNew(topic As %String, seq As %BigInt, myInt As %Integer, myLong As %BigInt, myBool As %Boolean, myDouble As %Double, myFloat As %Float, myBytes As %RawString, myString As %String, myArray As %RawString) As %Status [ Private, ServerOnly = 1 ]
{
    Set ..topic=topic
    Set ..seq=seq
    Set ..myInt=myInt
    Set ..myLong=myLong
    Set ..myBool=myBool
    Set ..myDouble=myDouble
    Set ..myFloat=myFloat
    Set ..myBytes=myBytes    
    Set ..myString=myString

    Set myArrayCount=$LISTLENGTH(myArray)
    For i=1:1:myArrayCount {
        Do ..myArray.Insert($LIST(myArray,i))
    }
    Return $$$OK
}

ClassMethod GETNEWID() As %Integer
{
    Quit $INCREMENT(^SIMPLECLASSUNIQ)
}

}
