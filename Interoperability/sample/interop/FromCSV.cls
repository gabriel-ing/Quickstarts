Class sample.interop.FromCSV Extends Ens.BusinessService
{

// Define the Inbound Adapter

Parameter ADAPTER = "EnsLib.File.InboundAdapter";

// Create a property for the message target (i.e. where the messages will be sent)

Property MessageTarget As %String;

// Add the message Target to message settings. 

Parameter SETTINGS = "MessageTarget:Basic";

Method OnProcessInput(pInput As %Stream.FileCharacter) As %Status
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
        set st=..SendRequestAsync(..MessageTarget, msg)

        if ('st){
        $$$LOGERROR("Cannot call Process for ProductID "_$Piece(line, ",", 1))
        }
        
    }
    quit $$$OK
}

}
