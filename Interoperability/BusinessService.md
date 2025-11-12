## Business Service
The service class should extend the superclass `Ens.BusinessService`.
### Using an Inbound Adapter
The business service is the process which populates the transaction request message we have created. To do this, an **Inbound Adapter** is required. The adapter recieves the data coming into the production. Inbound adapters could recieve data from one of the following examples: 

- Reading a file 
- REST Request
- Email 

There are a wide number of inbound adapters availble, but its also possible to create custom adaptors using the `Ens.InboundAdapter` superclass. 

Inbound adaptors commonly require additional settings, like for a File adapter it needs a directory and a file name pattern to watch for files. When a business service uses an adaptor, these adaptor settings are made available within the Production Configuration portal. The inbound adapter in use needs to be set using the ADAPTER parameter: 

```
Parameter ADAPTER = "EnsLib.file.InboundAdapter";
```

### Adding Configureable settings

We can  add configurable settings to the Business Service by creating properties for the settings, then adding them to the SETTINGS parameter. In this example we are going to make the message target configurable, this is the business process that the message will be sent to. To do this, we add 

```
Property MessageTarget As %String;
```
To create the property to store the setting and 
```
Parameter SETTINGS = "MessageTarget:Basic";
```
The term ":Basic" means that this will be added to the Basic Settings portion of the Production Configuration Settings.  

### Defining Logic

The actions behind the business service are defined using the `OnProcessInput` method, this is the function which is activated by the Inbound Adaptor. In our case, the adapter is activated by detecting a file in the directory it is watching (defined by the FilePath Setting). The adaptor reads this file and passes it to the business service as a `%Stream.FileCharacter` Object, which is the text-file object. We therefore define the `OnProcessInput` with the following:

```
Method OnProcessInput(pInput As %Stream.FileCharacter) As %Status
{...}
```

The method needs to:
1. Create an order number for the whole transaction - this can be done by incrementing a global. 
2. Read each line of the CSV file 
3. Populate a new TransactionMessage with the values from each line, as well as the Order Number and exact date and time of processing
4. Send the message Asynchronously (without waiting for a response)

These can be implemented in the following way: 

#### Create an order number: 

```
    // Increment the Order ID
    set OrderId = $Increment(^OrderCounter)
```
#### Read each line of CSV file: 
```
// Read the headers line of the csv file
set headers = pInput.ReadLine()

while 'pInput.AtEnd{  // Iterate over each line until the end of the file
    set line = pInput.ReadLine()

    // ... Populate and send message
 } 
```

#### Populate the message
This uses `$Piece(line, "," , n)` to split each line by commas and access each value with its position `n` (note indexing starts at 1, not 0). 

It also requires some rudimentary data handling using the `$ZString(<string>, "*W")` function to strip the whitespaces and the unary operator `+` to convert the string to an integer

There are more sophisticated ways to handle CSV files, for example using the [CSV Record Wizard](https://docs.intersystems.com/iris20252/csp/docbook/DocBook.UI.Page.cls?KEY=EGDV_recmap#EGDV_recmap_create_wizard), but for this introductory guide, we will stick to the rudimentary CSV parsing. 

```
        // Create a new message for each transaction line
        set msg = ##class(sample.interop.TransactionMessage).%New()
        
        // Set the Order ID as the transaction order ID
        set msg.OrderId = OrderId
        
        // Add the processing date and time as an ODBC format datetime string
        set msg.DateTime = $ZDATETIME($HOROLOG, 3)

        // Set the values from the line of the csv file
        set ProductId = $Piece(line, ",", 1)
        set msg.ProductId = +$ZStrip(ProductId, "*W")

        set msg.ProductName = $Piece(line, ",",2)
        set Quantity = $Piece(line, ",", 3) 
        set msg.Quantity = +$ZStrip(Quantity, "*W")
```
#### Sending the message

Messages can be sent with the inherited `Ens.BusinessService` method `SendRequestAsync()`, this takes in two parameters, the target (where the message is sent, commonly a business process) and the message itself:

```
       // Send Asynchronous request
        set st=..SendRequestAsync(..MessageTarget, msg)
```

Asynchronous requests mean that the program will not wait for a response before proceeding to the next step. If a process should await a response, `SendRequestSync(pTargetDispatchName, pRequest, .pResponse, pTimeout)` can be used instead.

The `..` syntax means the `SendRequestAsync` and the `MessageTarget` property are both coming from the parent class, rather than having been defined within the `OnProcessInput` method. 

We can check that the message has successfully been sent: 
```
        if ('st){
        $$$LOGERROR("Cannot call Process for ProductID "_$Piece(line, ",", 1))
        }
```

`$$$LOGERROR()` is a shortcut to log an error to the Event log in the Production Configuration Portal, which can help provide some context to the error. Its also possible to log information, warnings or status codes (`$$$LOGINFO()`, `$$$LOGWARNING` and `$$$LOGSTATUS`) which can be helpful for debugging purposes. 

### Full Class
```
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
```
### Adding FromCSV service to Production

To add the Business Service to the production, open the Production configuration portal and click the `+` next to services. This will open the `Business Service Wizard`. Choose the `sample.interop.FromCSV` service class from `Service Class` dropdown. You can give the service a name or leave it blank - the default name is just the name of the class. Nothing else is required, so Click `OK` to add the service to the production. 

![Business Service Wizard](Images/BusinessServiceWizard.png)

Once added, it will appear in the list of Business Services with a grey dot. 

![Business Service in list](Images/ServiceInList.png)

The color of the dot represents the status of the component: 
- Grey - disabled
- Light green - enabled but not in use
- Dark green - enabled and running
- Red - it has one or more errors.

Before this Business Service can function, we need to define the following: 

- File Path - The directory to watch for new transaction files coming in
- File Spec - The file pattern to look for.
- Archive Path - The directory to put the processed files into. 
- MessageTarget - The business process where the message is sent. This was the setting we defined in the service class using the `SETTINGS` parameter. 

There are also some additional settings, including the frequency at which it checks for a new file and the number of pooled transaction files before this job functions. For now though, we are only going to worry about the essential settings above. 

To see the settings, click on the new Business Service in the list. The setting panel should open on the right hand side. Scroll to basic settings and fill out as follows: 

We define: 

- File Path: /home/irisowner/fileInput 
    - This is the In-file directory. Change this to the location on your system. If the directory does not exist, the service will error, so make sure to create the directory.
- File Spec: *.csv
    - This is the pattern of file which the adapter is looking for. * is a wildcard character, meaning any number of letters before ".csv", the file extension. 
- Archive Path: /home/irisowner/ProcessedFiles
    - This is the location the original files are moved to after processing. As with the File Path, this directory needs to exist, so change it on your system. 
- MessageTarget: sample.interop.ProcessTransactionRouter
    - This is the name of the business service we will send our TransactionMessages to. We will define this class in the next step.

We also click the `Enabled` checkbox to enable the business service. 

![Business Service Settings](Images/BusinessServiceSettings.png)

