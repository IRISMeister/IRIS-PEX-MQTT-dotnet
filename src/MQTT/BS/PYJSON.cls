/// Description
Class MQTT.BS.PYJSON Extends EnsLib.MQTT.Service.Passthrough
{

Method OnProcessInput(pInput As EnsLib.MQTT.Message, pOutput As %RegisteredObject) As %Status
{
	#dim tSC As %Status = $$$OK
	#dim e As %Exception.AbstractException
	
	Try {
		#; $$$LOGINFO("Topic:"_pInput.Topic_" Value:"_pInput.StringValue)
		#; Set ^log($INCREMENT(^log))=pInput.StringValue

		Set seq=$INCREMENT(^seq)
		#; Avroはバイナリ形式なので、(文字列ではなく)バイト列として渡す。
		Set tSC=..Save(seq,pInput.Topic,##class(%SYS.Python).Bytes(pInput.StringValue))

		Set tRequest=##class(MQTT.REQ.Simple).%New(seq,pInput.Topic)
		Set tSC=##super(tRequest,pOutput)
	} Catch e {
		Set tSC=e.AsStatus()
	}
		
	Quit tSC
}

Method Save(seq As %Numeric, topic As %String, avromsg As %RawString) As %Status [ Language = python ]
{
	import SaveJSON2IRIS as s
	
	s.save(seq,topic,avromsg)
}

}
