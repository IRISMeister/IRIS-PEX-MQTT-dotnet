Class MQTT.Client Extends %RegisteredObject
{

ClassMethod Main()
{
    Set o=..%New()
    Set tSC=o.Init()
    Set m=o.Connect()
    While(1) {
        If $G(^kill)=1 Return
        Do o.Receive(m)
    }
}

Method Connect()
{
    Set KeepAliveInterval=30 // default is $$$KeepAliveInterval=60
    Set m=##class(%Net.MQTT.Client).%New("tcp://mqttbroker:1883","irisclient",1,KeepAliveInterval)
    Set cleansession=1
    Set tSC=m.Connect(,,cleansession)
    Set tSC=m.Subscribe("/XGH/EKG/ID_123/PYAVRO/#")

    Return m
}

Method Receive(m)
{
    ;[now,topic,message,SQLCODE] 
    Set timeout=10000 ; msec
    Set message=""
    set c=0

    #; "MQTT Library","Disconnected"を防ぐには？
    Do m.IsConnected(.c)
    If c=0 { 
        W "disconnected",! 
        Set m=$$Connect()
    }
    Set tSC=m.Receive(.topic,.message,timeout)
    If topic'="" {
        set seq=1
        set now=$ZDATETIME($H,3)
        Set tSC=..Save(seq,topic,##class(%SYS.Python).Bytes(message))

        w topic," ",now," TimedOut:",m.TimedOut,!
    }
    else {
        W "No data",!
        If $$$ISERR(tSC) { zw tSC }
    }
    Return
}

Method Save(seq As %Numeric, topic As %String, avromsg As %RawString) [ Language = python ]
{
	# import IRISDIR/mgr/python/SaveAVRO.py
	import SaveFastAVRO as s
	
	s.save(seq,topic,avromsg)
}

Method Init() [ Language = python ]
{
	import SaveFastAVRO as s
	
	s.getschema()
	return True
}

}
