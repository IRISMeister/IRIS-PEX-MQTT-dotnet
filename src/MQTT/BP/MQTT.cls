/// 
Class MQTT.BP.MQTT Extends Ens.BusinessProcessBPL
{

Storage Default
{
<Type>%Storage.Persistent</Type>
}

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='Ens.Request' response='Ens.Response' height='2000' width='2000' >
<sequence xend='200' yend='450' >
<trace value='request.%Id()' xpos='200' ypos='250' />
<call name='call1' target='NoOp' async='1' xpos='200' ypos='350' >
<request type='%Library.Persistent' >
<assign property="callrequest" value="request" action="set" languageOverride="" />
</request>
<response type='%Library.Persistent' />
</call>
</sequence>
</process>
}

}
