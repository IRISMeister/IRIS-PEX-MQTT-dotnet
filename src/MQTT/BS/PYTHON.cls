Class MQTT.BS.PYTHON Extends EnsLib.MQTT.Service.Passthrough
{

Method OnProcessInput(pInput As EnsLib.MQTT.Message, pOutput As %RegisteredObject) As %Status
{
	#dim tSC As %Status = $$$OK
	#dim e As %Exception.AbstractException
	
	Try {
		$$$LOGINFO("Topic:"_pInput.Topic_" Value:"_pInput.StringValue)
		Set ^log($INCREMENT(^log))=pInput.StringValue
		#; Avroはバイナリ形式なので、(文字列ではなく)バイト列として渡す。
		Set tSC=..SaveAvro(##class(%SYS.Python).Bytes(pInput.StringValue))

		Set tSC=##super(pInput,pOutput)
	} Catch e {
		Set tSC=e.AsStatus()
	}
		
	Quit tSC
}

Method SaveAvro(avromsg As %RawString) As %Status [ Language = python ]
{
	# import IRISDIR/mgr/python/saveAvro2IRIS.py
	import saveAvro2IRIS as s
	
	s.save(avromsg)
}

}
