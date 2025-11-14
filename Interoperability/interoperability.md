# Interoperability

Interoperability is the ability for systems and devices to seamlessly interact, work together and exchange information across different platforms and standards. 

In InterSystems IRIS, an interoperable system, or production, is completed by three main process types: 

- Business Services
    - Responsible for recieving incoming signals.
- Business Processes
    - Responsible for conditional routing of messages, as well as required transformations of data. 
- Business Operations
    - Responsible for Downstream processes including information being sent to external applications. Business Operations may also be intermediate processes like querying a database, where the response is passed back to a business process before the final outputs.


There are two other crutial components: 

- Adapters 
    - These are connectors that help receive input data (inbound adapters) or pass on output in a suitable format (outbound adapters). 
    - There are many pre-configured adapters, including file reading and writing, sending and receiving emails, querying external databases and using common transfer protocols like REST, SOAP or TCP. For more info, see the [extended list of pre-configured adapters](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=EGIN_options_connectivity).

- Messages
    - These contain the information being passed between the different components. 

(Placeholder image)

![alt text](Images/InteropIntroPlaceholder.png)


# Creating a simple Interoperability Production


This guide walks through the creation of a basic code-first interoperability production to show how these productions can be built.

While this guide focuses more on the code underlying the production, its worth noting that a key value of the InterSystems IRIS Interoperability Production system is the productions can be configured, messages tracked and settings changed, within a low-code user interface. Therefore, alongside the code shown throughout this guide, the Production Configuration page of the management portal will also be shown, with various settings being configured from here. To access this page, go to: 

 http://localhost:52773/csp/user/EnsPortal.ProductionConfig.zen?$NAMESPACE=USER& 

 (Assuming the IRIS instance is mapped to local port 52773, and the production is in the user namespace).

 Or navigate directly from the management portal homepage with: 

Interoperability -> Configure -> Production -> GO 

![Accessing Production Configuration](Images/AccessingProductionConfiguration.png)


## Design Brief:

The aim of this walkthrough is to design a system to process transactions. This system will be very simple, but will guide the process of building a simple interoperability production with InterSystems IRIS. The process is as follows: 

1. A transaction is initialized by a CSV file with the order details being added to the Transactions `InFile` folder.
2. Business service reads the transaction data (via an Inbound adapter) and sends a request to a Business Process
3. The Business process sends a request to a Business Operation to update the stock database. 
4. The Business Operation sends a response with the updated stock values.
5. The Business Process checks if any of the updated stock values are less than 5, if so, sends a low-stock warning email.


Interoperability productions are built from classes, as is standard within InterSystems IRIS. Each component is generally a separate class, unless there are multiple instances of the same class, potentially with different settings (e.g. two file-reading Business Services that read from different directories).

To build this production, we need the following components: 

1. `FromCSV` Business Service
2. `ProcessTransactionRouter` Business Process
3. `ToUpdateStock` Business Operation
4. `ToEmail` Business Operation

And the following messages: 

1. `TransactionMessage` Request. This can be reused between the business service and the business process, and between the business process and the stock updating business operation.
2. `StockMessage` Response. This is a response message that sends data back from the database (Business Operation) to the business class.

We also need to build the table which stores our stock data. 

Again, every one of these components, including the message classes and the data table, are InterSystems IRIS classes. In fact, the production itself is also an Intersystems IRIS class, although is usually only seen as a UI. 

The functionality of these classes will be written in a mix of ObjectScript and XML. For an introduction on the basics of InterSystems IRIS classes and ObjectScript, see [Getting Started with Server-side coding](../ServerSideCoding/Getting%20started%20with%20server-side%20coding.md)


### Data Format

The transaction data is going to have the following: 

|ProductID|ProductName|Quantity|
|-|-|-|
|101|Keyboard| 1|
|102|Monitor| 2|

And the stock table will have the following details: 

| DateLastSold | ProductId | ProductName    | Quantity |
|--------------|-----------|----------------|----------|
|              | 101       | Computer Mouse | 17       |
|              | 102       | Monitor        | 13       |
|              | 103       | Laptop         | 7        |

### Interoperability Value

Using an Interoperability production for such a simple example does add unneccessary complexity, however the value of interoperability productions is to create complex systems where every interaction between components is tracked and logged. The in-build ability to examine the content of every message request and response makes it much easier to identify errors and bugs in the process, and quickly recognise and disable broken features. 

Furthermore, this is all performed in the context of InterSystems IRIS's secure and reliable systems. Once developed, much of the process, including building new productions with existing components, can be done in a low-code environment, so can be handled by non-developers. Settings can also be changed and components disabled while the production is operating. 

So while this guide does overcomplicate a relatively straight-forward process, it is designed to explain how complex systems can be built piece-by-piece.

### Build Order 
The components can be built in any order, but some general rules for ordering the build are:
1. Its good to build messages early on, because all components will need to interact with messages. 
2. Building back to front is often preferable because you can test Business Operations and Processes using dummy messages with the Testing features. 

As such, this guide is ordered in the following order: 
- The Table of Stock Data (`StockTable`)
- Initialising the production
- Messages (`TransactionMessage` and `StockMessage`)
- Business Operations (`ToUpdateStock` and `ToEmail`)
- Business Process (`ProcessTransactionRouter`)
- Business Service (`FromCSV`)

There is no reason why this couldn't be built in any other order, but the testing facilities work best in this order, meaning you can ensure each component works before building the next component. Feel free to skip to the pages for any component you are interested in though. 

An additional consideration is that there are many different parts to be built. The example being defined here has four different Business Hosts, two message type, a persistent class to create the data table, and the production setting file itself. While the order laid out in this guide is logical, it is by no means the only correct order to create an interoperability production. In fact,  used almost the exact reverse order.

Each of these classes are going to be individually defined below, together with some details on the process behind their design. For the full coded example, see [final github link](). Alternative examples can be found at: [Reddit demo link](https://github.com/intersystems-community/iris-interoperability-template/tree/master) and a similar guide available on the [developer community](https://community.intersystems.com/post/intersystems-iris-first-time-let%E2%80%99s-use-interoperability)


## Creating the Stock Database

Before starting to create our production, we will make the data table which our stock information.

To create the stock database, we can use a perisistent class. To keep it simple, we only need the ProductId,  ProductName, Quantity in stock, and date last sold. To make it easier to populate the table, we will also add a class method which creates a new object and saves it to the table. 

```
Class sample.StockTable Extends %Persistent
{

Property ProductId As %Integer [ Required ];

// Set the Product ID to be the Index 
Index ID On ProductId [ IdKey ];

Property ProductName As %String;

Property Quantity As %Integer [ Required ];

Property DateLastSold As %DateTime;

ClassMethod CreateNew(pid As %Integer, pName As %String, quantity As %Integer) As %Status
{
    // Create new item
    set newItem = ##class(sample.StockTable).%New()

    // Populate the information based on method call parameters
    set newItem.ProductId = pid
    set newItem.ProductName = pName
    set newItem.Quantity = quantity

    // Save the item 
    set sc = newItem.%Save()
}
}

```

### Populating table 

Now we have saved the above class, we can populate the table by running the following in the IRIS command line (ensure it is in the USER namespace): 

```
do ##class(sample.StockTable).CreateNew(101, "Computer Mouse", 17)
do ##class(sample.StockTable).CreateNew(102, "Monitor", 13)
do ##class(sample.StockTable).CreateNew(103, "Laptop", 7)
do ##class(sample.StockTable).CreateNew(104, "Desktop PC", 11)
do ##class(sample.StockTable).CreateNew(105, "Keyboard", 11)
```

Now, we can open the SQL Editor at [http://localhost:52773/csp/sys/exp/%25CSP.UI.Portal.SQL.Home.zen?$NAMESPACE=USER](http://localhost:52773/csp/sys/exp/%25CSP.UI.Portal.SQL.Home.zen?$NAMESPACE=USER) and view the table with:

```
SELECT 
ID, DateLastSold, ProductId, ProductName, Quantity
FROM sample.StockTable
```
Which outputs the following table 

|  ID  | DateLastSold | ProductId | ProductName    | Quantity |
|------|--------------|-----------|----------------|----------|
| 101  |              | 101       | Computer Mouse | 17       |
| 102  |              | 102       | Monitor        | 13       |
| 103  |              | 103       | Laptop         | 7        |
| 104  |              | 104       | Desktop PC     | 11       |
| 105  |              | 105       | Keyboard       | 11       |


# Creating the Production

A good first step is creating the production, as this is required to add settings to the production components. To create a new production, open the [Production Configuration Portal](http://localhost:52773/csp/user/EnsPortal.ProductionConfig.zen?$NAMESPACE=USER&) and click `New` at the top of the page.

![Production Configuration Portal](Images/ProductionConfiguration.png)

You will be greated with the following pop-up.

![Create Production Wizard](Images/CreatingProductionWizard.png)

The files for this guide are going to be saved in the sample.interop package, so this is a sensible place for the production to live. Enter `sample.interop` in the Package box. You can also give the production a name and description. The production name can be generic, e.g. "Production", and the description is optional, but it is always good practice to use names and descriptions that make it easier to understand what the production is for. 


The production is saved within an XML block in an IRIS class sharing the name of the production. The settings can be directly changed within this XML data, though it is generally easier to use the management portal. 

### Production Class

For reference, this is the completed production class including all the components in the process and the settings selected: 

```xml
Class sample.interop.Production Extends Ens.Production
{

XData ProductionDefinition
{
<!-- Production definition -->
<Production Name="sample.interop.Production" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>

    <!-- Business Operation 1 -->
  <Item Name="sample.interop.ToUpdateStock" Category="" ClassName="sample.interop.ToUpdateStock" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>

    <!-- Business Operation 2 -->
  <Item Name="sample.interop.ToEmail" Category="" ClassName="sample.interop.ToEmail" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">

    <!-- Outbound Email Adapter Settings -->
    <Setting Target="Adapter" Name="Credentials">Gmail</Setting>
    <Setting Target="Adapter" Name="From">FirstName.LastName@gmail.com</Setting>
    <Setting Target="Adapter" Name="Recipient">warehouse@example.com</Setting>
    <Setting Target="Adapter" Name="SMTPPort">465</Setting>
    <Setting Target="Adapter" Name="SMTPServer">smtp.gmail.com</Setting>
    <Setting Target="Adapter" Name="SSLConfig">SSLConfig</Setting>

  </Item>

    <!-- Business Process -->
  <Item Name="sample.interop.TransactionProcessRouter" Category="" ClassName="sample.interop.TransactionProcessRouter" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>

    <!-- Business Service-->
  <Item Name="sample.interop.FromCSV" Category="" ClassName="sample.interop.FromCSV" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    
    <!-- Configurable Business Service Setting-->
    <Setting Target="Host" Name="MessageTarget">sample.interop.TransactionProcessRouter</Setting>

    <!-- Inbound File Reader Adapter Settings-->
    <Setting Target="Adapter" Name="ArchivePath">/home/irisowner/ProcessedFiles</Setting>
    <Setting Target="Adapter" Name="FilePath">/home/irisowner/fileInput</Setting>
    <Setting Target="Adapter" Name="FileSpec">*.csv</Setting>
  </Item>

</Production>
}
}

```











