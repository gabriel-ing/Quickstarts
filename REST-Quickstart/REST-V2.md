# REST Quickstart

There are many ways to create a REST API with IRIS, this guide shows how to create a REST API using a specification-first approach. This method is the recommended way to easily create REST APIs. 

A specification first approach means that the base classes for the REST process are automatically generated using an OpenAPI specification (OpenAPI is also known as Swagger).

In this example, we are going to create a REST API for a basic task management system. 


 ## Persistent class

 Before starting with the REST Portion of this guide, we need to create a table to contain the task data. This will be queried using the REST. 

```
Class TaskManager.tasks Extends (%Persistent, %JSON.Adaptor)
{

Property Title As %String;

Property Description As %String;

Property Status As %String(VALUELIST = ",Pending,In-Progress,Complete");

Property DueDate As  %Library.Date;

Property DateLastModified As  %Library.Date;
}
```

## Creating a Specification

The first step of designing a REST API is considering what information needs to be passed between the Client (the front-end calling the HTTP methods) and the Server (the database). 

In our case, each task is going to have the following properties: 

- ID
- Title 
- Description
- Status
- Due Date
- Date Last modified

Depending on the request, there will be slight differences as to what information is required in the request. 

- A GET request queries the database, it will return all properties for each item
- A POST request creates a new task, this requires: 
    - Title
    - Description
    - Due Date
- A Put request updates a task, this needs an ID, as well as whatever is being updated. 

Creating a full OpenAPI specification is beyond the scope of this guide, but below are some tips to get started: 
 - You can create and edit a specification with the online Swagger Editor at https://editor.swagger.io/
 - You should include an `operationId` name for each method as this will become the method name in the implementation class
 - The specification needs to be OpenAPI 2.0 specification in JSON format.
 - Generative AI can create first drafts of simple specifications.


 ## Creating the REST Classes

 The easiest way to create a REST API in InterSystems IRIS is using the ^%REST routine. Open an InterSystems IRIS terminal and run the following: 

 ```
 do %^REST
 ```

 This will start a command line interface to create a new REST application: 
```
 USER>do ^%REST
REST Command Line Interface (CLI) helps you CREATE or DELETE a REST application.
Enter an application name or (L)ist all REST applications (L): 
```
Enter the name of your new application: 
```
TaskManager
```
```
REST application not found: TaskManager
Do you want to create a new REST application? Y or N (Y): y
```

```
File path or absolute URL of a swagger document.
If no document specified, then create an empty application.
OpenAPI 2.0 swagger: 
```
Enter the filepath of your specification:
```
/home/irisowner/task-manager-swagger.json
```

```
OpenAPI 2.0 swagger document: /home/irisowner/task-manager-swagger.json
Confirm operation, Y or N (Y): 

-----Creating REST application: TaskManager-----
CREATE TaskManager.spec
GENERATE TaskManager.disp
CREATE TaskManager.impl
REST application successfully created.

Create a web application for the REST application? Y or N (Y): Y
Specify a web application name beginning with a single '/'. Default is /csp/TaskManager
Web application name: 

-----Deploying REST application: TaskManager-----
Application TaskManager deployed to /csp/TaskManager
```

This process creates a new web application at `<serverlocation>:<port>/csp/TaskManager`. The endpoints that can be queried are then added to this. For example, in the specification, we have the following: 

```json
"paths":{
    "/tasks":{
      "get":{
        "summary":"Get all tasks",
        "operationId":"getTasks",
        ... 
      }}}
```

This specifies that if we send a GET request to `<serverlocation>:<port>/csp/TaskManager/tasks`, we call the operation `getTasks` (implemented below).


Using the ^%REST routine creates an Implementation Class (`impl.cls`) and a specification class (`spec.cls`). The specification class contains the OpenAPI specification in an XData block within the class. Any changes to the desired REST design should be done by editing the specification here, with the changes automatically propagating to the implementation class.


## Implementation class

The implementation class (`Impl.cls`) will be generated with stub methods for the operations detailed in the OpenAPI specification. This will be in the package name given as the name for the new application (`TaskManager`) in this example. 


ClassMethod getTasks() As %DynamicObject
{
    //(Place business logic here)
    //Do ..%SetStatusCode(<HTTP_status_code>)
    //Do ..%SetHeader(<name>,<value>)
    //Quit (Place response here) ; response may be a string, stream or dynamic object
}



### POST request implementation

Let's start by writing the implementation of the POST request to create a task. To do this, we simply need to create an instance of our persistant class, import the post request body with `.%JSONImport(body)` and save it to our database. 

```
ClassMethod createTask(body As %DynamicObject) As %DynamicObject
{
    // Instantiate new task object
    set task = ##class(TaskManager.tasks).%New()

    // Import Json body
    set status =  task.%JSONImport(body)
    
    // Json Import error handling
    if ('status=1) {
        do ..%SetStatusCode(406)
        quit "Error importing JSON"}
    
    // Save object to database
    set savestatus =  task.%Save()

    // Saving object error handling
    if 'savestatus=1 do ..%SetStatusCode(500) quit "Error saving object"

    // Populate response 
    set response = {}
    set response.Response = "tasked saved to the database as ID: "_task.%Id() 
    // Return response
    return response
}
```
Test with a POST request as follows:
```http
POST http://localhost:52773/csp/TaskManager/tasks
Content-Type: application/json
Accept: application/json

    {
    "Title": "Finish API integration",
    "Description": "Implement the API endpoints for creating tasks",
    "Status": "Pending",
    "DueDate": "2025-11-25"
    }

```


### GET requests

Next, lets implement the GET requests. Here we have two endpoints, one general `/tasks` which returns all the information in the database, and one `/tasks/<taskid>` which just returns one. Lets start with the latter of these because it is easier to implement: 

```
ClassMethod getTaskById(taskId As %String) As %DynamicObject
{
    // Open Task by ID
    set task = ##class(TaskManager.tasks).%OpenId(taskId)

    // Error handling
    if 'task do ..%SetStatusCode(404) quit "Task not found"

    // Export the object as a JSON string called output 
    // The . means object is being passed by reference so the method can modify it.
    do task.%JSONExportToString(.output)
    
    // return the JSON string
    return output
}
```
We can then send the following get request:
```http
GET http://localhost:52773/csp/TaskManager/tasks/1
Authorization: Basic SuperUser SYS
```

and recieve: 

```
HTTP/1.1 200 OK
Date: Thu, 20 Nov 2025 16:21:17 GMT
Server: Apache
CACHE-CONTROL: no-cache
EXPIRES: Thu, 29 Oct 1998 17:04:19 GMT
PRAGMA: no-cache
CONTENT-LENGTH: 140
Connection: close
Content-Type: application/json

{
  "Title": "Finish API integration",
  "Description": "Implement the POST endpoint for creating tasks",
  "Status": "Pending",
  "DueDate": "2025-11-25"
}
```

The getTasks() function is a bit more tricky to implement because we need to create a JSON array containing all of our individual rows of the database as JSON objects. There are many ways to do this, for example it is possible to retrieve all the IDs with SQL, iterate over the IDs opening each file and exporting a JSON string. 

The simplest way to do this might be to use Intrinsic SQL Functions to create JSON object, and JSON Arrays provided in InterSystems IRIS.

To create a JSON object from each row we can use the following syntax
```sql
SELECT JSON_OBJECT("prop-name":ColName) FROM tablename; 
/*Or in our case*/
SELECT JSON_OBJECT('ID':ID,'Title':Title,'Description':Description,'DueDate':DueDate,'DateLastModified':DateLastModified,'Status':Status) FROM TaskManager.tasks;
```

To aggrgate a column into a JSON array we can use: 
```sql
SELECT JSON_ARRAYAGG(ColName) FROM tableName
/*To combine these for our case*/

SELECT JSON_ARRAYAGG(JSON_OBJECT(
    'ID':ID,'Title':Title,'Description':Description,'DueDate':DueDate,'DateLastModified':DateLastModified,'Status':Status
)) FROM TaskManager.tasks;

```

We can then use Embedded SQL in ObjectScript to run this, exporting the JSON Array as a new variable:

```sql
// General case
&sql(SELECT NAME INTO :name FROM tableName WHERE ID = 1)
write name

// Our case: 
&sql(SELECT JSON_ARRAYAGG(
    JSON_OBJECT('ID':ID,'Title':Title,'Description':Description,'DueDate':DueDate,'DateLastModified':DateLastModified,'Status':Status))
    INTO :jsonArray
    FROM TaskManager.tasks)

```

And in full: 
```
ClassMethod getTasks() As %DynamicObject
{
    &sql(SELECT JSON_ARRAYAGG(
        JSON_OBJECT('ID':ID,'Title':Title,'Description':Description,
        'DueDate':DueDate,'DateLastModified':DateLastModified,'Status':Status)) 
        INTO :jsonArray
        FROM TaskManager.tasks)

    return jsonArray
}
```

We can test this with the following get request:
```http
GET http://localhost:52773/csp/TaskManager/tasks
Authorization: Basic SuperUser SYS
```

### PUT request

The PUT request updates a task. The main forseeable use for this is to update the task status from "Pending", to "In-progress", to "Complete", but its also good to allow for updates for Typos in the title and description. The code for this is identical to the POST `createTasks()` function, except rather than creating a new object, it opens an existing one with `.%OpenID`.

```

```

Test with a PUT request as follows:
```http
PUT http://localhost:52773/csp/TaskManager/tasks/1
Authorization: Basic SuperUser SYS
Content-Type: application/json
Accept: application/json

    {
    "Status": "Complete",
    }

```

## Requesting and Debugging

API requests can be sent with a number of REST clients, including from Python and Javascript/TypeScript. Postman is a recommended dedicated REST client for testing and using a REST service, while for simple queries, you can save the query (in the format given above) as a .http file, and then send it from VS Code with the [REST Client Extension](https://marketplace.visualstudio.com/items?itemName=humao.rest-client). 

To debug the process, as it is not possible to directly print anything to a terminal, one easy method is to easily set a global variable. For example: 

```
set ^test = "Here"

do task.%JSONExportToString(.output) 

set ^test(1) = "Done JSON Export"
```

For more sophisticated debugging, there is a [debugging tool](https://docs.intersystems.com/components/csp/docbook/DocBook.UI.Page.cls?KEY=GVSCO_debug#GVSCO_debug_rest) included in the [VS Code ObjectScript Extensions pack](https://marketplace.visualstudio.com/items?itemName=intersystems-community.objectscript-pack) which includes functionality to debug REST APIs.