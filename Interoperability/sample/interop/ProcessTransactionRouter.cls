Class sample.interop.ProcessTransactionRouter Extends Ens.BusinessProcess
{

Parameter RuleAssistClass = "EnsLib.MsgRouter.RuleAssist";

XData BPL [ XMLNamespace = "http://www.intersystems.com/BPL" ]
{
<process language='objectscript' request='sample.interop.TransactionMessage' response='Ens.Response' >
<context>
<property name='sampleinteropToUpdateStock' type='sample.interop.StockMessage' instantiate='0' />
</context>
    <call name="CallUpdateStockDB" target="sample.interop.ToUpdateStock" async="0">
        <request type="sample.interop.TransactionMessage">
            <assign property="callrequest.ProductId" value="request.ProductId" action="set" />
            <assign property="callrequest.ProductName" value="request.ProductName" action="set" />
            <assign property="callrequest.Datetime" value="request.Datetime" action="set" />
            <assign property="callrequest.Quantity" value="request.ProductQuantity" action="set" />
        </request>
        <response type="sample.interop.StockMessage">
            <assign property="context.Stock" value="callresponse.CurrentStock" action="set" />
            <assign property="context.ProductId" value="callresponse.ProductId" action="set"/>
            <assign property="context.ProductName" value="callresponse.ProductName" action="set"/>
        </response>
    </call>

    <if condition="context.Stock &lt;5">
        <true>
            <call name="CallToEmail" target="sample.interop.ToEmail" async="1">
                <request type="sample.interop.TransactionMessage">
                    <assign property="callrequest.ProductID" value="context.ProductId" action="set"/>
                    <assign property="callrequest.ProductName" value="context.ProductName" action="set"/>
                    <assign property="callrequest.Quantity" value="context.Stock" action="set"/>
                </request>
            </call>
        </true>
    </if>
</process>
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
