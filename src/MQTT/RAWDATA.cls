/// Production response class. Target of data transformation
/// that converts from MQTT topic and payload into a persistent object.
Class MQTT.RAWDATA Extends (%Persistent, %XML.Adaptor, Ens.Util.RequestBodyMethods)
{

Property seq As %BigInt;

Property topic As %String;

Property myInt As %Library.Integer;

Property myLong As %Library.BigInt;

Property myBool As %Library.Boolean;

Property myDouble As %Library.Double;

Property myFloat As %Library.Float;

Property myString As %Library.String;

Property myFilename As %Library.String;

Property l1 As %Integer;

Property l2 As %Integer;

Property l3 As %Integer;

Property l4 As %Integer;

Property l5 As %Integer;

Property l6 As %Integer;

Property l7 As %Integer;

Property l8 As %Integer;

Property b1 As %Integer;

Property b2 As %Integer;

Property b3 As %Integer;

Property b4 As %Integer;

Property b5 As %Integer;

Property b6 As %Integer;

Property b7 As %Integer;

Property b8 As %Integer;

Index idxseq On seq;

ClassMethod INSERT(seq, topic, myBytes, longarray) As %Status
{
#define DATAPOINTNUM 8
    For i=1:1:$$$DATAPOINTNUM { Set b(i)=0, l(i)=0 }

    Set jsonlong=[].%FromJSON(longarray)
    For i=1:1:$$$DATAPOINTNUM { Set l(i)=jsonlong.%Get(i-1) }
    Set jsonbytes=[].%FromJSON(myBytes)
    For i=1:1:$$$DATAPOINTNUM { Set b(i)=jsonbytes.%Get(i-1) }

    &SQL(INSERT INTO RAWDATA (seq, topic, b1,b2,b3,b4,b5,b6,b7,b8, l1,l2,l3,l4,l5,l6,l7,l8) VALUES (:seq, :topic, :b(1),:b(2),:b(3),:b(4),:b(5),:b(6),:b(7),:b(8), :l(1), :l(2), :l(3), :l(4), :l(5), :l(6), :l(7), :l(8)))

    Return %ROWID
    //Quit $$$OK
}

/*
ClassMethod New(seq, p1, p2, p3, p4, p5, p6, p7, p8) As Solution.RAWDATA
{
    Set p=##class(Solution.RAWDATA).%New()
    Set p.seq=seq
    Set p.p1=p1
    Set p.p2=p2
    Set p.p3=p3
    Set p.p4=p4
    Set p.p5=p5
    Set p.p6=p6
    Set p.p7=p7
    Set p.p8=p8
    Quit p
}
*/
ClassMethod GETNEWID() As %Integer
{
    Quit $INCREMENT(^RAWDATAUNIQ)
}

Storage Default
{
<Data name="RAWDATADefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>seq</Value>
</Value>
<Value name="3">
<Value>topic</Value>
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
<Value>myString</Value>
</Value>
<Value name="10">
<Value>myFilename</Value>
</Value>
<Value name="11">
<Value>l1</Value>
</Value>
<Value name="12">
<Value>l2</Value>
</Value>
<Value name="13">
<Value>l3</Value>
</Value>
<Value name="14">
<Value>l4</Value>
</Value>
<Value name="15">
<Value>l5</Value>
</Value>
<Value name="16">
<Value>l6</Value>
</Value>
<Value name="17">
<Value>l7</Value>
</Value>
<Value name="18">
<Value>l8</Value>
</Value>
<Value name="19">
<Value>b1</Value>
</Value>
<Value name="20">
<Value>b2</Value>
</Value>
<Value name="21">
<Value>b3</Value>
</Value>
<Value name="22">
<Value>b4</Value>
</Value>
<Value name="23">
<Value>b5</Value>
</Value>
<Value name="24">
<Value>b6</Value>
</Value>
<Value name="25">
<Value>b7</Value>
</Value>
<Value name="26">
<Value>b8</Value>
</Value>
</Data>
<DataLocation>^MQTT.RAWDATAD</DataLocation>
<DefaultData>RAWDATADefaultData</DefaultData>
<IdLocation>^MQTT.RAWDATAD</IdLocation>
<IndexLocation>^MQTT.RAWDATAI</IndexLocation>
<StreamLocation>^MQTT.RAWDATAS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
