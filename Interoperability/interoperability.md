# Interoperability

Interoperability is the ability for systems and devices to seamlessly interact, work together and exchange information across different platforms and standards. 

An example of an interoperability system is an automated loan application checking service. A user submits an application, leading to automated queries to different loan providers to check what loan they could provide. Finally the interoperable system might provide a response to the user in the form of sending an email. At several points in this system, there may be rules-based processes, e.g. to check the outcome of a loan request before writing an acceptance or denial email. 

In InterSystems IRIS, an interoperable system, or production, is completed by three main process types: 

- Business Services
    - Responsible for recieving and parsing incoming signals.
    - Loan example: the Business Service would recieve the data from the submitted form.

- Business Processes
    - Responsible for based routing of messages, as well as required transformations of data. 
    - Loan example: Processes would send the required data to operations to check different loan providers, and apply conditional logic to call acceptance or rejection email operations.

- Business Operations
    - Responsible for Downstream processes, this may include intermediate processes like querying a database before the final outputs.
    - Loan example: Responsible for querying loan providers and sending decision email.

There are two other crutial components: 

- Adapters 
    - These are connectors that help read input data (inbound adaptors) or create output data in a suitable format (outbound adaptors).
    - Loan example: A JSON adapter may read data that has been submitted via POST request to an API endpoint. 

- Messages
    - These contain the information being passed between the different components. 


    