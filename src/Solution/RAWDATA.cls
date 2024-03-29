/// Production response class. Target of data transformation
/// that converts from MQTT topic and payload into a persistent object.
Class Solution.RAWDATA Extends (%Persistent, %XML.Adaptor, Ens.Util.RequestBodyMethods)
{

Property seq As %BigInt;

Property p1 As %Integer;

Property p2 As %Integer;

Property p3 As %Integer;

Property p4 As %Integer;

Index idxseq On seq;

ClassMethod INSERT(seq, list) As %Status
{
    For i=1:1:4 { Set p(i)=0 }
    Set count=$LISTLENGTH(list)
    For i=1:1:count {
        Set p(i)=$LIST(list,i)
    }
    &SQL(INSERT INTO RAWDATA (seq, p1,p2,p3,p4) VALUES (:seq, :p(1),:p(2),:p(3),:p(4)))
    Quit $$$OK
}

ClassMethod New(seq, p1, p2, p3, p4) As Solution.RAWDATA
{
    Set p=##class(Solution.RAWDATA).%New()
    Set p.seq=seq
    Set p.p1=p1
    Set p.p2=p2
    Set p.p3=p3
    Set p.p4=p4
    Quit p
}

ClassMethod GETNEWID() As %Integer
{
    Quit $INCREMENT(^RAWDATAUNIQ)
}

}
