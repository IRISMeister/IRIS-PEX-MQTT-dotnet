Class App.Installer
{

XData MyInstall [ XMLNamespace = INSTALLER ]
{
<Manifest>
  <Default Name="DBNAME" Value="AVRO"/>
  <Default Name="APPPATH" Dir="/opt/irisbuild" />
  <Default Name="SOURCESPATH" Dir="${APPPATH}src" />
  <Default Name="RESOURCE" Value="%DB_${DBNAME}" /> 
  <Default Name="ProductionName" Value="MQTT.Production"/>

  <Namespace Name="${DBNAME}" Code="${DBNAME}" Data="${DBNAME}" Create="yes" Ensemble="1">
    <Configuration>
      <Database Name="${DBNAME}" Dir="${APPPATH}${DBNAME}" Create="yes" Resource="${RESOURCE}"/>
    </Configuration>

    <Import File="${SOURCESPATH}" Recurse="1"/>
    <Production Name="${ProductionName}" AutoStart="1"/>  
  </Namespace>
</Manifest>
}

ClassMethod setup(ByRef pVars, pLogLevel As %Integer = 3, pInstaller As %Installer.Installer, pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
  Quit ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "MyInstall")
}

ClassMethod Initialize() As %Status
{
  // Call the setup method above.
  set st = ..setup()
  $$$ThrowOnError(st)
 
  #; enable callin. This is required only if you want to try callin.py
  kill prop
  Set tSC=##class(Security.Services).Get("%service_callin",.prop)
  Set prop("Enabled")=1
  Set tSC=##class(Security.Services).Modify("%service_callin",.prop) 

  return $$$OK
}

}
