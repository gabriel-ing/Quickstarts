Class sample.interop.ToUpdateStock Extends Ens.BusinessOperation
{

XData MessageMap
{
<MapItems>
        <MapItem MessageType="sample.interop.TransactionMessage">
            <Method>UpdateDatabase</Method>
        </MapItem>
    </MapItems>
}

Method UpdateDatabase(pReq As sample.interop.TransactionMessage, Output pResp As sample.interop.StockMessage) As %Status
{
        // Open the stock item in the database
        set stockItem = ##class(sample.StockTable).%OpenId(pReq.ProductId)

        // Update the current stock
        set stockItem.Quantity = stockItem.Quantity - pReq.Quantity
        
        // Update the last sale date
        set stockItem.DateLastSold = pReq.DateTime
        
        // Save the edited item
        set sc = stockItem.%Save()

        // Log Error message if it fails to save
        if 'sc $$$LOGERROR(##class(%SYSTEM.Status).GetErrorText(sc))

        // Create the response message
        set pResp = ##class(sample.interop.StockMessage).%New()
        // Populate the response message
        set pResp.CurrentStock = stockItem.Quantity
        set pResp.ProductId = pReq.ProductId
        set pResp.ProductName = pReq.ProductName

        quit $$$OK
}

}
