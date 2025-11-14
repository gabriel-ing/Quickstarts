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
    // Create a new email object
    set email = ##class(%Net.MailMessage).%New()
    
    // Create the string for the warning email
    set emailText = "Warning! Stock for "_pReq.ProductName_" (ProductID: "_pReq.ProductId_") Is running low. Currently, there are only "_pReq.Quantity_" Units left in stock."

    // Write the email text to the email object
    do email.TextData.Write(emailText)

    // Set the email subject
    set emailSubject = "Stock Warning PID: "_pReq.ProductId
    set email.Subject = emailSubject

    // Use the outbound adapter to send the email
    set tSc = ..Adapter.SendMail(email)

    // Check if the email has been sent, and log upon failure
    if '$$$ISOK(tSc) $$$LOGERROR("Email Send Fail")

    // Exit method returning the email send status    
    quit tSc
}

}
