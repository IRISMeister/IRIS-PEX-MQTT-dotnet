Class Solution.SimpleClassC Extends (%Persistent, %XML.Adaptor, Ens.Util.RequestBodyMethods)
{

Property topic As %String;

Property seq As %BigInt;

// It's may not a good idea to use generated class as a member.

Property SimpleClass As dc.SimpleClass;

Index idxseq On seq;

Method %OnNew(topic As %String, seq As %BigInt) As %Status [ Private, ServerOnly = 1 ]
{
    Set ..topic=topic
    Set ..seq=seq
    &SQL(select ID into :id from dc.SimpleClass where "<myLong>k__BackingField"=:seq)
    Set ..SimpleClass=##class(dc.SimpleClass).%OpenId(id)
    Return $$$OK
}

}
