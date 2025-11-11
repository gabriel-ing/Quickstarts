Class sample.interop.CsvFileService Extends Ens.BusinessService
{

Parameter ADAPTER = "EnsLib.File.InboundAdapter";

Method OnProcessInput(pInput As %FileCharacterStream, Output pOutput As %RegisteredObject) As %Status
{
    // Increment the Order ID
    set OrderId = $Increment(^OrderCounter)
    
    // Read the headers line of the csv file
    set headers = pInput.ReadLine()

    while 'pInput.AtEnd{
        set line = pInput.ReadLine()

        // Create a new message for each transaction line
        set msg = ##class(sample.interop.TransactionMessage).%New()
        
        // Set the Order ID as the transaction order ID

        set msg.OrderId = OrderId
        
        // Add the processing date and time in ODBC format
        set msg.DateTime = $ZDATETIME($HOROLOG, 3)

        // Set the values from the line of the csv file
        set ProductId = $Piece(line, ",", 1)
        set msg.ProductId = +$ZStrip(ProductId, "*W")

        set msg.ProductName = $Piece(line, ",",2)
        set Quantity = $Piece(line, ",", 3) 
        set msg.Quantity = +$ZStrip(Quantity, "*W")

        // Send Asynchronous request
        set st=..SendRequestAsync("sample.interop.BPWizardRouter", msg)

        if ('st){
        $$$LOGERROR("Cannot call PrcMain Process for ProductID "_$Piece(line, ",", 1))
        }
        
    }
    quit $$$OK
}

}
