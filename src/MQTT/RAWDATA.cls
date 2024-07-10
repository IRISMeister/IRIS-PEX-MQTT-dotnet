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

// a list of binary array
//Property myArray As list Of %Library.RawString(STORAGEDEFAULT = "list");

Property b1 As %Integer;

Property b2 As %Integer;

Property b3 As %Integer;

Property b4 As %Integer;

Property b5 As %Integer;

Property b6 As %Integer;

Property b7 As %Integer;

Property b8 As %Integer;

Property l1 As %Integer;

Property l2 As %Integer;

Property l3 As %Integer;

Property l4 As %Integer;

Property l5 As %Integer;

Property l6 As %Integer;

Property l7 As %Integer;

Property l8 As %Integer;

Index idxseq On seq;

ClassMethod INSERT(seq, topic,bytes,longarray) As %Status
{
#define DATAPOINTNUM 8
    For i=1:1:$$$DATAPOINTNUM { Set b(i)=0, l(i)=0 }

    Set json=[].%FromJSON(bytes)
    Set jsonlong=[].%FromJSON(longarray)
    For i=1:1:$$$DATAPOINTNUM { Set b(i)=json.%Get(i-1), l(i)=jsonlong.%Get(i-1) }

    &SQL(INSERT INTO RAWDATA (seq, topic, b1,b2,b3,b4,b5,b6,b7,b8,l1,l2,l3,l4,l5,l6,l7,l8) VALUES (:seq, :topic, :b(1),:b(2),:b(3),:b(4),:b(5),:b(6),:b(7),:b(8), :l(1), :l(2), :l(3), :l(4), :l(5), :l(6), :l(7), :l(8)))

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

}
