Class sample.interop.ProcessTransactionRouter Extends Ens.BusinessProcessBPL
{

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='sample.interop.TransactionMessage' response='Ens.Response' component="1" >
    <context>
        <property name='CurrentStock' type='%Integer'/>
    </context>
    <sequence>
        <call name='CallToUpdateStock' target='sample.interop.ToUpdateStock' async='0'>
            <request type='sample.interop.TransactionMessage' >
            <assign property="callrequest" value="request" action="set" languageOverride="" />
            </request>
            <response type='sample.interop.StockMessage' >
                <assign property="context.CurrentStock" value="callresponse.CurrentStock" action="set" />
            </response>
        </call>
        <if name='CheckStock' condition='context.CurrentStock &lt; 5'>
            <true>
                <call name='CallToEmail' target='sample.interop.ToEmail' async='1' >
                    <request type='sample.interop.TransactionMessage' >
                        <assign property="callrequest.ProductId" value="request.ProductId" action="set"/>
                        <assign property="callrequest.ProductName" value="request.ProductName" action="set"/>
                        <assign property="callrequest.Quantity" value="context.CurrentStock" action="set"/>
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
