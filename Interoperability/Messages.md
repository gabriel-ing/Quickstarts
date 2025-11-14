# Messages

Message are used to pass information between components of the Interoperability production. Every component of the interoperability production will interact with one or more messages, either by sending a request to another component, or being activated on receipt of a message. Messages are therefore a good place to start when creating an Interoperability production. 

To create a message, the first place to start is considering what information needs to flow between components. In our example, we need to pass the key information from each transaction, like the ProductId and quantity. 

### Reusability

Messages can be reused in different places within an interoperability production. Not every property of a message needs to be filled every time a message is used, only those with the `[ Required ]` keyword are needed on every occasion. 

In our example, we will reuse a request message between the Business Service and the Business Production as well as between the Business Process and both Business Operations. However, when sending the warning about stock, we do not need to include the Order ID that cause the stock to drop below the threshold for sending a warning email. The message will still have the property availble, but it will just not be assigned in this instance.

It can be a good idea to reuse messages in different places to avoid overcomplicating the process. 

### Superclasses

Messages are generally stored in tables to allow them to be tracked and searched. For this reason, messsages should extend the `%Persistent` superclass to allow messages to be saved to individual databases. Messages should also extend the `Ens.Request` or `Ens.Response` superclasses, depending on whether it is a request message or a response message. 

Messages are also recommended to extend `%XML.Adatper` as this allows the body of the message to be viewed in XML format the management portal.


### Request Vs Response Messages

A response message is one that is sent back to a component that has send a request message, this can simply be a 'receipt' to confirm the message has been received, or can be information being returned to the sender. For example, a business process would send a **request** to a business operation to query a database, while the operation would send a **response** back to the business process with the results of the query.  

## Request Message

We are going to simply create a message that has the columns within the original transaction CSV, as well as an additional value for Order ID, so the messages can be grouped by order ID in future, and a DateTime value to keep track of the date at which the order was processed. 

Note, we are making a design choice to send a single message for each row of the CSV file. This design makes sense as we can update the stock for each item in the transaction individually. In other systems however, it may make sense to include all the data in the original file as a single message. 

```
Class sample.interop.TransactionMessage Extends (%Persistent, Ens.Request, %XML.Adaptor)
{

    Property OrderId As %Integer;

    Property DateTime As %String;

    Property ProductId As %Integer;

    Property ProductName As %String;

    Property Quantity As %Integer;

}
```

## Response Message

We will also define a response message to return information on the current stock level from the Business Operation. This message only needs to contain the CurrentStock level, as it will be sent from a context where the ProductId and ProductName is already known, however to make it easier to track our messages, it is worth including the ProductId in the response as well.

```
Class sample.interop.StockMessage Extends ( %Persistent, %Ens.Response, %XML.Adapter)
{
    Property ProductId As %Integer;

    Property CurrentStock As %Integer;
}
```
