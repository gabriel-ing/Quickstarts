## Business Processes

Now we have the functions at either end of the production, the next to do is connect them using a conditional routing process. The rules behind the message routing are simple. When a message arrives, the `ToUpdateStock` operation needs to be called synchronously to recieve the output of the new stock number. If the resulting stock is low, in this example we shall put a limit of 5 units, the business process sends an additional call to `ToEmail`. 

There are several ways to create a business process, including creating custom ObjectScript business processes extending the `Ens.BusinessProcess` superclass. However, the easiest way is to create a business process based on Business Process Language, BPL. 

BPL uses XML format to create a simple hierarchical flow. 

The easiest way to create a business process is by using the Business Process Designer UI, which result of this is to create a new class which extends `Ens.BusinessProcessBPL`. This class contains the process within XML (XData). 

For a demonstrations of how to use the business process designer UI, or the Business Rule creator UI, which is a very similar method, see the following videos: 
- [Creating A new BPL Process](https://www.youtube.com/watch?v=JFGfZfs8iJ4)
- [Creating Complex Descision Logic](https://www.youtube.com/watch?v=SZBRm4rtue8)

To access the Business Process Designer UI, navigate from the management portal homepage to: 

`Interoperability -> Build -> Business Processes -> Go`

The remainder of this guide will focus on the logic behind the process and the configuration required to perform the desired message routing, however will not focus on where to access these settings using the UI. 

**If you do chose to use the Business Process Designer, please note that in order to use the created process as a standalone component, you have to tick the `Is Component` checkbox in the general process settings.**

### Descision Logic

The required Business Process flow is very simple:

1. Recieve a primary message from the Business Service
2. Send a request message containing the information in the primary request message to `ToUpdateStock` Operation
3. Receive the `ToUpdateStock` response and store the new `CurrentStock` value.
4. Check if the updated Stock Value (`CurrentStock`) is less than 5
    - If so, Send Request message to `ToEmail` containing the `ProductName`, `ProductId` and `CurrentStock` 


## Creating a Business Process Language Class

As mentioned above, when creating a class using BPL, the class must extend `Ens.BusinessProcessBPL`:

```
Class sample.interop.ProcessTransactionRouterRules Extends Ens.BusinessProcessBPL
{...}
```

The Business Process logic is stored inside this class as XML data (XData):
```
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{ <...>}
```

### Process settings

The first step is to define a `<process>` tag, this includes general settings for the overall process. The settings required here are: 
 - The `request` message class (`sample.interop.TransactionMessage`)
 - The `response` message class - as we don't need to send any information back to the business service, we can use the general response class `Ens.Response`
 - The `language` - this is the programming language that the underlying code is implemented in. This can be `objectscript`, `python` or `basic`. We can leave it as `objectscript`. 
 - Whether this class can be a `component` by itself, this needs to be set to `"1"` (true) to allow us to use the process directly in a production. 

This is implemented as follows: 

```xml
<process language='objectscript' request='sample.interop.TransactionMessage' response='Ens.Response' component="1" >
<!-- All other code -->
</process>
 ```

We then need to define Context Properties. Context properties are variables that are only available within the Business Process scope, i.e. are only available for each individual time a Business Process is run. This is done with the `<context>` and `<property>` tags. 

Throughtout the entire business logic, the only variable needed which is not availble within the Primary request is the `CurrentStock` value which is recieved from the call request to the `ToUpdateStock` business operation. Therefore, this is the only value required in the context. To create this property, we also have to give it a type. We can also give it a default value, with the `instantiate` keyword. The following is used to create the property: 

```xml
<context>
    <property name='CurrentStock' type='%Integer' instantiate='0' />
</context>
```

### Sequence 

The `<sequence>` tag defines the flow of the process logic. This is the sequence that will be called upon recieving a request. The process ends when this sequence tag is closed: 

```xml
<sequence>
    <!-- Actions, calls, conditionals and loops -->
</sequence>
```

### Call to `ToUpdateStock`

To send a call to another Production Component, the `<call>` tag is used. Calls are sent primarily to Business Operations, but it is also possible for Business Processes to call other Business Processes. 

A call needs the following options: 
    - A unique `name` for the call
    - A `target` - this is the _name_ of the production component the call is being sent to. Production components are by default given the name of the component class, so in our case that would be `sample.interop.ToUpdateStock`. However, it is possible to give a component an alternative name when adding it to the production.
    - `async` - this defines whether the call is performed synchronously (`async='0'`) or Asynchronously (`async=1`). Synchronously means it will wait for the response before continuing with the rest of the business logic, while asynchronously means it will continue without the response. 

```xml
<call name='CallToUpdateStock' target='sample.interop.ToUpdateStock' async='0'>
```

Inside the `<call>` tag we also need to define the `<request>` and `<response>` messages, and the action taken for both of these. The primary action taken is to assign values _to_ the `request` message, and assign values _from_ the `response` message. We assign values using the `<assign>` tag, with the keywords for `property` (the property being defined), `value` (the new value), and `action` which is `set` to assign (if your property is a list or array, there are other options like append, insert or remove).

When assigning values, `callrequest` means the request message being made within the `<call>` block, and `<callresponse>` is the response message from the call request. The `request` message is the primary request that was initially recieved by the business process. 

When creating our call to `ToUpdateStock`, we can assign the `callrequest` to be the same as the primary `request`:

```xml
<request type='sample.interop.TransactionMessage' >
    <assign property="callrequest" value="request" action="set" />
</request>
```

This defines the request message type to be the `sample.interop.TransactionMessage`, then assigns the call request to be the same as the primary request. 

The Business Operation returns a `sample.interop.StockMessage` response type. From this, we need to take the `CurrentStock` value, and assign it to the context property by the same name that we defined above: 

```xml
<response type='sample.interop.StockMessage' >
    <assign property="context.CurrentStock" value="callresponse.CurrentStock" action="set" />
</response>
```
In this way, we have implemented a complete call to the `ToUpdateStock` Business operation, that assigns the call request to be the same as the primary request, and on receipt of the new value in the stock table, assigns this value to a context property. Below shows the full call request: 

```xml
<call name='CallToUpdateStock' target='sample.interop.ToUpdateStock' async='0'>
    <request type='sample.interop.TransactionMessage' >
        <assign property="callrequest" value="request" action="set" />
    </request>
    <response type='sample.interop.StockMessage' >
        <assign property="context.CurrentStock" value="callresponse.CurrentStock" action="set" />
    </response>
</call>
```

### Conditional Call to `ToEmail`

Following the response from the `ToUpdateStock` operation, we have a value for the current stock level for the product being processed. We now want to send a warning email if the stock is low (arbitrarily defined to be less than 5 units). 

To implement this process, we need a conditional in the business process that checks the `CurrentStock` value, and, if it is less than 5, sends a call to the `ToEmail` business process.

To create a basic if condition, we can use the `<if>` tag, this creates a conditional with `<true>` or `<false>` events (only one of these is required). We need to give this tag a unique name (e.g. `CheckStock`) and a `condition`. The condition is done using a text string, that includes the value and a comparison. e.g. `context.PropertyName = 1`. There are some characters that can't be used in BPL, and this includes the  greater than and less than symbols, ">" and "<" These need to be replace with `&gt;` and `&lt;`. Therefore, our condition is: 

```xml
<if name='CheckStock' condition='context.CurrentStock = 5'>
<true>
<!-- Logic if true (ToEmail Call) -->
</true>
</if>
```

Applying the same principles as for the first call, we can define the second call. This time, the target is the `sample.interop.ToEmail` component, and we do not need to await a response so we can set `async='1'`. For the request class, we can use our standard `sample.interop.TransactionMessage` class, whilst the response class can be the generic `Ens.Response`. 

The call request message needs to be populated with the
- ProductId from the primary request
- ProductName from the primary request
- CurrentStock from the context (saved from the previous call)

```xml
<call name='CallToEmail' target='sample.interop.ToEmail' async='1' >
<request type='sample.interop.TransactionMessage' >
    <assign property="callrequest.ProductId" value="request.ProductId" action="set"/>
    <assign property="callrequest.ProductName" value="request.ProductName" action="set"/>
    <assign property="callrequest.Quantity" value="context.CurrentStock" action="set"/>
</request>
<response type='Ens.Response' />
</call>
```

## Next Steps

There we have it! Our Business process should now be fully functioning. The full code can be seen below. Now we can move onto the final step of the build, creating the first step of the production [the Business Service Class](BusinessService.md)

## Complete Class

```xml
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
    
}
```