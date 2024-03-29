/// Interoperability production XML, should be viewed in the management portal.
Class Solution.MQTT Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="Solution.MQTT" TestingEnabled="true" LogGeneralTraceEvents="true">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="From_MQTT_PT" Category="" ClassName="EnsLib.MQTT.Service.Passthrough" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigNames">Decode_MQTT_PEX,Process_MQTT_PEX</Setting>
    <Setting Target="Adapter" Name="Topic">/ID_123/XGH/EKG/PT/#</Setting>
    <Setting Target="Adapter" Name="Url">tcp://mqttbroker:1883</Setting>
  </Item>
  <Item Name="From_MQTT_EXT" Category="" ClassName="Solution.BS.MQTTEXT" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigNames">Process_MQTT</Setting>
    <Setting Target="Adapter" Name="Topic">/ID_123/XGH/EKG/EXT/#</Setting>
    <Setting Target="Adapter" Name="Url">tcp://mqttbroker:1883</Setting>
  </Item>
  <Item Name="Process_MQTT" Category="" ClassName="Solution.BP.MQTT" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Process_MQTT_PEX" Category="" ClassName="EnsLib.PEX.BusinessProcess" PoolSize="3" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="%remoteSettings">TargetConfigNames=NoOp_PEX</Setting>
    <Setting Target="Host" Name="%remoteClassname">dc.MQTTProcess</Setting>
    <Setting Target="Host" Name="%gatewayHost">netgw</Setting>
    <Setting Target="Host" Name="%gatewayPort">55556</Setting>
    <Setting Target="Host" Name="%gatewayExtraClasspaths">/app/mylib1.dll</Setting>
  </Item>
  <Item Name="NoOp_PEX" Category="" ClassName="EnsLib.PEX.BusinessOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="%remoteClassname">dc.MQTTOperationNoOp</Setting>
    <Setting Target="Host" Name="%gatewayHost">netgw</Setting>
    <Setting Target="Host" Name="%gatewayPort">55556</Setting>
    <Setting Target="Host" Name="%gatewayExtraClasspaths">/app/mylib1.dll</Setting>
  </Item>
  <Item Name="Decode_MQTT_PEX" Category="" ClassName="EnsLib.PEX.BusinessOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="%remoteClassname">dc.MQTTOperation</Setting>
    <Setting Target="Host" Name="%gatewayHost">netgw</Setting>
    <Setting Target="Host" Name="%gatewayPort">55556</Setting>
    <Setting Target="Host" Name="%gatewayExtraClasspaths">/app/mylib1.dll</Setting>
  </Item>
  <Item Name="From_MQTT_PEX" Category="" ClassName="Solution.BS.MQTTPEX" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="%remoteClassname">dc.MQTTService</Setting>
    <Setting Target="Host" Name="%gatewayHost">netgw</Setting>
    <Setting Target="Host" Name="%gatewayPort">55556</Setting>
    <Setting Target="Host" Name="%gatewayExtraClasspaths">/app/mylib1.dll</Setting>
    <Setting Target="Adapter" Name="Topic">/ID_123/XGH/EKG/PEX/#</Setting>
    <Setting Target="Adapter" Name="Url">tcp://mqttbroker:1883</Setting>
    <Setting Target="Host" Name="%remoteSettings">TargetConfigNames=Process_MQTT</Setting>
  </Item>
  <Item Name="From_MQTT_PEX2" Category="" ClassName="Solution.BS.MQTTPEX" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="%remoteClassname">dc.MQTTService2</Setting>
    <Setting Target="Host" Name="%gatewayHost">netgw</Setting>
    <Setting Target="Host" Name="%gatewayPort">55556</Setting>
    <Setting Target="Host" Name="%gatewayExtraClasspaths">/app/mylib1.dll</Setting>
    <Setting Target="Adapter" Name="Topic">/ID_123/XGH/EKG/PEX2/#</Setting>
    <Setting Target="Adapter" Name="Url">tcp://mqttbroker:1883</Setting>
    <Setting Target="Host" Name="%remoteSettings">TargetConfigNames=Process_MQTT</Setting>
  </Item>
  <Item Name="From_MQTT_PEX3" Category="" ClassName="Solution.BS.MQTTPEX" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="%remoteClassname">dc.MQTTService3</Setting>
    <Setting Target="Host" Name="%gatewayHost">netgw</Setting>
    <Setting Target="Host" Name="%gatewayPort">55556</Setting>
    <Setting Target="Host" Name="%gatewayExtraClasspaths">/app/mylib1.dll</Setting>
    <Setting Target="Adapter" Name="Topic">/ID_123/XGH/EKG/PEX3/#</Setting>
    <Setting Target="Adapter" Name="Url">tcp://mqttbroker:1883</Setting>
    <Setting Target="Host" Name="%remoteSettings">TargetConfigNames=Process_MQTT</Setting>
  </Item>
</Production>
}

}
