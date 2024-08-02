Class MQTT.Dispatcher Extends %CSP.REST
{

Parameter CONVERTINPUTSTREAM = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/reset" Method="POST" Call="Reset" Cors="true" />
<Route Url="/measure" Method="POST" Call='Measure' Cors="true" />
</Routes>
}

ClassMethod Reset() As %Status
{
    Set sql="DELETE FROM MQTT.SimpleClass"
    Set result=##class(%SQL.Statement).%ExecDirect(,sql)

    Set info={"SQLCODE":(result.%SQLCODE)}
	write info.%ToJSON()
    return $$$OK
}

ClassMethod Measure() As %Status
{
    Set sql="SELECT count(*) cnt,{fn TIMESTAMPDIFF(SQL_TSI_FRAC_SECOND,MIN(ReceiveTS),MAX(ReceiveTS))} diff FROM MQTT.SimpleClass"
    Set result=##class(%SQL.Statement).%ExecDirect(,sql)
    Do result.%Next()

    Set info={"SQLCODE":(result.%SQLCODE),"Count":(result.cnt),"Diff":(result.diff)}
	write info.%ToJSON()
    return $$$OK
}

}
