Class MQTT.REQ.Simple Extends (%Persistent, %XML.Adaptor, Ens.Util.RequestBodyMethods)
{

Property seq As %BigInt;

Property topic As %String;

Method %OnNew(seq As %BigInt, topic As %String) As %Status [ Private, ServerOnly = 1 ]
{
    Set ..seq=seq
    Set ..topic=topic
    Return $$$OK
}

Storage Default
{
<Data name="SimpleDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>seq</Value>
</Value>
<Value name="3">
<Value>topic</Value>
</Value>
</Data>
<DataLocation>^MQTT.REQ.SimpleD</DataLocation>
<DefaultData>SimpleDefaultData</DefaultData>
<IdLocation>^MQTT.REQ.SimpleD</IdLocation>
<IndexLocation>^MQTT.REQ.SimpleI</IndexLocation>
<StreamLocation>^MQTT.REQ.SimpleS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
