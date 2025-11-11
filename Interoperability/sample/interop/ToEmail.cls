Class sample.interop.ToEmail Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.EMail.OutboundAdapter";

XData MessageMap
{
<MapItems>
        <MapItem MessageType="sample.interop.TransactionMessage">
            <Method>SendEmail</Method>
        </MapItem>
    </MapItems>
}

Method SendEmail(pReq As sample.interop.TransactionMessage, Output pResp As Ens.Response) As %Status
{
    $$$LOGINFO("sending email...")
    set email = ##class(%Net.MailMessage).%New()
    
    set emailText = "Warning! Stock for "_pReq.ProductName_" (ProductID: "_pReq.ProductId_") Is running low. Currently, there are only "_pReq.Quantity_" Units left in stock."

    do email.TextData.Write(emailText)

    set emailSubject = "Stock Warning PID: "_pReq.ProductId
    set email.subject = emailSubject

    set tSc = ..Adapter.SendMail(email)

    if '$$$ISOK(tSc) $$$LOGERROR("Email Send Fail")
        
    quit tSc
}

}
