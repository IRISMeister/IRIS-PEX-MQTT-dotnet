Class MQTT.BO.NoOp Extends Ens.BusinessOperation [ Language = objectscript ]
{

Method OnMessage(request As %Library.Persistent, Output response As %Library.Persistent) As %Status
{
    #dim tSC As %Status = $$$OK
    return tSC
}

}
