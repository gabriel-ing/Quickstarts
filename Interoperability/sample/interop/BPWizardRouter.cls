/// 
Class sample.interop.BPWizardRouter Extends Ens.BusinessProcessBPL
{

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='sample.interop.TransactionMessage' response='Ens.Response' component="1" >
<context>
<property name='sampleinteropToUpdateStock' type='sample.interop.StockMessage' instantiate='0' />
</context>
<sequence xend='495' yend='175' >
<call name='CallToUpdateStock' target='sample.interop.ToUpdateStock' async='0'>
<request type='sample.interop.TransactionMessage' >
<assign property="callrequest" value="request" action="set" languageOverride="" />
</request>
<response type='sample.interop.StockMessage' >
<assign property="context.sampleinteropToUpdateStock" value="callresponse" action="set" languageOverride="" />
</response>
</call>
<if name='CheckStock' condition='context.sampleinteropToUpdateStock.CurrentStock &lt; 5' xpos='200' ypos='350' xend='320' yend='715' >
<true>
<call name='CallToEmail' target='sample.interop.ToEmail' async='1' xpos='310' ypos='512' >
<request type='sample.interop.TransactionMessage' >
<assign property="callrequest" value="context.sampleinteropToUpdateStock" action="set" languageOverride="" />
</request>
<response type='Ens.Response' />
</call>
</true>
</if>
</sequence>
</process>
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
