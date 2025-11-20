# REST Quickstart

There are many ways to create a REST API with IRIS, this guide shows a very simple code-first example as a place to get started. 

This guide is going to show the entire process to completely demonstrate how a REST service functions. It is worth noting that there are shortcuts available to easily create boilerplate code and stub-functions, for example using an OpenAPI specification.  

REST APIs use two classes, a Dispatch class, and an implementation class. The Dispatch class defines the endpoints, routes and which methods are called in response to an HTTP request. The Implementation class defines the methods that are called.

	GET Request ---> <server>/api/endpoint ---> Dispatch class ---> Implementation class

In the simple example below, we are going to create a service that receives information on a pet and saves it into the database. For this, we need also need a %persistent class to store in the database. This database storage could also be achieved with SQL queries.

To create the simplest REST service therefore we simply need: 

- A Dispatch class to route the requests - `disp.cls`
- A Implementation class to create the methods - `impl.cls`
- A Persistent class to store data in database. - `person.cls` 
- To create a web-application
	
## Persistent class

Our data is in the following format: 
```json
{
	"PetId": 1,
	"Name" : "Fido",
	"Type": "Dog"
}
```

We can create the following Persistent class to represent this as a data table.

```
Class petapi.Pet Extends (%Persistent, %JSON.Adaptor)
{
	// ID value 
	Property PetId As %Integer; 
	
	// Make Pet Id the index key
	Index PetIDX On PetId [ IdKey ];
	
	// Name of Pet
	Property Name As %String;
	
	// Type of animal
	Property Type as %String ;
	
}
```
The class inherits from `%Persistent` and `%JSON.Adaptor`. 

`%JSON.Adaptor` makes it easier to parse data into and from JSON. 

 `%Persistent` class defines an object that can be saved to the database which means an object can be created using:

```
set dog = ##class(petapi.Pet).%New()
```
Properties set with: 
```
set dog.PetId = 1
set dog.Name = "Fido"
set dog.Type = "Dog"
```
and saved to the database with: 
```
dog.%Save()
```
## Dispatch class

Now let's create the dispatch class. For this guide, we are going to create two API routes: 
- A POST Request to `/petapi/pet` to add an animal to the database
- A GET Request to `/petapi/pet/<PetId>` to retrieve the info of a specific pet. 

The dispatch class  inherits from `%CSP.REST`

```
Class petapi.disp Extends %CSP.REST{...}
```

The routes are defined in XML data in an XData block called `UrlMap` within the dispatch class. Each route has an endpoint location (url), the HTTP method being used, and a function that is called. 

```xml
	XData UrlMap [ XMLNamespace = "https://www.intersystems.com/urlmap" ]
    {
	    <Routes>
	        <Route Url="/pet" Method="POST" Call="AddPet"/>
	        <Route Url="/pet/:pid" Method="GET" Call="GetPet"/>
	    </Routes>
    }
```

You can define a variable in the URL, that is used in the function. In our example, the petId value is entered as part of the URL, so the pet with `petId = 5` is available with a GET request to `/petapi/pet/5` . This is processed with the `:pid`, and is a parameter in the GetPet (below). 

The methods in the dispatch class are normally used to check the request input and populate the response message. There is no reason that the logic for implementing the required functionality couldn't be included in this method, but its good practice to have a separate implementation class, `impl.cls`, to handle the implementation logic. 

The ClassMethod for handling the GetPet method is shown below. 

``` 
	ClassMethod GetPet(pid As %Integer) As %Status
		{
		    Try {

			    // Boilerplate code for ensuring the content recieved is valid JSON
		        Do ##class(%REST.Impl).%SetContentType("application/json")
		        If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
	
				// Call to implementation class
		        Set response = ##class(petapi.impl).GetPet(pid)
		        
				// Write implementation class response as REST response
		        Do ##class(%REST.Impl).%WriteResponse(response)
		       
		    } 
		    // Error handling
		    Catch (ex) {
		        Do ##class(%REST.Impl).%SetStatusCode("400")
		        return {"errormessage": "Client error"}
		    }
		    Quit $$$OK
		}
```
This function checks that the input is ok, then calls the corresponding method in the implementation class (shown below).

	Set response=##class(petapi.impl).GetPet(pid)

Then, it writes the response of the implementation class function as the API response. 

The corresponding POST function is similar (full code below), but doesn't take any parameters. Instead, the request body (the data being send) is found with `%request.Content.Read()`:

```
ClassMethod AddPet() As %Status
{
    Try {
	    // Boilerplate code for handling content type (JSON)
        Do ##class(%REST.Impl).%SetContentType("application/json")
        If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
	        
        // Call implementation Class
        Set response=##class(petapi.impl).AddPet(%request.Content.Read())
        
		// Write implementation response as REST response
        Do ##class(%REST.Impl).%WriteResponse(response)
    } 
    // Error Handling 
    Catch (ex) {
        Do ##class(%REST.Impl).%SetStatusCode("400")
        return {"errormessage": "Client error"}
    }
    Quit $$$OK
}
```

## Implementation Class

In the dispatch class above, we point to the class methods `AddPet()` and `GetPet()` from `petapi.impl`, e.g.:

```
Set response = ##class(petapi.impl).GetPet(pid)
```

We now need to define these class methods in the implementation class:
	

```
Class petapi.impl Extends %CSP.REST
{
    ClassMethod AddPet(body As %DynamicObject) As %DynamicObject
    {...}
    ClassMethod GetPet(pid As %Integer) As %DynamicObject
    {....}
}
```

Here is the output of the class is a `%DynamicObject`. `%DynamicObject` is [essentially JSON format in ObjectScript](https://docs.intersystems.com/iris20252/csp/docbook/Doc.View.cls?KEY=GJSON_intro).

The `AddPet()` implementation method needs to:
- Open a new pet object
- Read the POST request body into the object
- Save the object to the database. 

This can be achieved with the following method: 

```
ClassMethod AddPet(body As %DynamicObject) As %DynamicObject
{
   Try{ 
    // Instantiate a new Pet object
    set pet = ##class(petapi.Pet).%New()
    
    // Read the JSON into the Pet object
    do pet.%JSONImport(body)
    
    // Save the object to the database
    set status = pet.%Save()
   
    // Error handling
    if (status=1){
         return {"Response": "Object Saved to Database"}
         }
    else { 
        Do ##class(%REST.Impl).%SetStatusCode("500")
        return {"Response": "Error saving object "}
    }
   } Catch{
        Do ##class(%REST.Impl).%SetStatusCode("500")
        return {"errormessage": "Server error"}
   }
}
```
	
The `petapi.impl.GetPet()` class method is similar - we open the pet object by it's ID and export it as a JSON object: 

```
ClassMethod GetPet(pid As %Integer) As %DynamicObject
{
    Try{
        // Checks if ID exists
        if (##class(petapi.Pet).%ExistsId(pid))
            {
                // Opens the pet object at pet ID
                set pet = ##class(petapi.Pet).%OpenId(pid)
                
                // Exports the pet as JSON and returns it
                do pet.%JSONExport(.ret)
                return ret
            }
        // Error handling - id not found
        else { 
            Do ##class(%REST.Impl).%SetStatusCode("404")
            return {"errormessage": "Pet not found"}
        }
    // Error handling - general error
    } Catch (ex){
        Do ##class(%REST.Impl).%SetStatusCode("500")
        return {"errormessage": "Server error"}
    }
}
```

### Creating the Web Application

The last step required is to create a web application for our API. This process can be easily done in the management portal (System Administration -> Security -> Applications -> Web applications) or using the terminal: 


```
// Set current namespace to SYS
Set $Namespace = "%SYS" 

// Set Web application options in the array options

// Web app is in USER namespace
Set options("NameSpace") = "USER" 

// Dispatch class 
Set options("DispatchClass") = "petapi.disp"

// Set authorisation to all 
Set options("MatchRoles") = ":%All" 

// Optional Description
Set options("Description") = "REST API for Pets" 

// Create application passing in the web app location and options array
Set sc = ##class(Security.Applications).Create("/petapi/", .options) 
```
### Sample Queries

The REST API at `<server>/petapi/pet` can now be queried with any REST client (e.g. Postman, Python Requests, Javascript's fetch, VS Code's REST Client extension or anywhere else). Below are example .http files for the requests, and body of the corresponding responses.    

##### POST request
	
```http
	POST http://localhost:52773/petapi/pet
	Content-Type: application/json
	
	{
	    "PetId": 1,
	    "Name": "Fido",
	    "Type": "Dog"
	}
```

Response Body:

	{ "Response": "Object Saved to Database" }

##### Get request 

```http
GET http://localhost:52773/petapi/pet/2
```

Response Body: 

```json
	{ 
	"PetId": 2, 
	"Name": "Whiskers", 
	"Type": "Cat" 
	}
```
## Full code
### Persistent Class 

```
Class petapi.Pet Extends (%Persistent, %JSON.Adaptor)
{
// ID value 
Property PetId As %Integer;
// Make Pet Id the primary key
Index PetIDX On PetId [ IdKey ];
// Name of Pet
Property Name As %String;
// Type of animal
Property Type As %String;
}
```
### Dispatch Class

```
Class petapi.disp Extends %CSP.REST
{

/// Handle Cors Request info
Parameter HandleCorsRequest = 1;

/// Define the REST Routes in XML format
XData UrlMap [ XMLNamespace = "https://www.intersystems.com/urlmap" ]
{
<Routes>
    <Route Url="/pet" Method="POST" Call="AddPet"/>
    <Route Url="/pet/:pid" Method="GET" Call="GetPet"/>
</Routes>
}

ClassMethod AddPet() As %Status
{
    Try {
        Do ##class(%REST.Impl).%SetContentType("application/json")
        If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
        //Call Implementation Class
        Set response=##class(petapi.impl).AddPet(%request.Content.Read())
		// Write implemenation response as REST response
        Do ##class(%REST.Impl).%WriteResponse(response)
    } Catch (ex) {
        Do ##class(%REST.Impl).%SetStatusCode("400")
        return {"errormessage": "Client error"}
    }
    Quit $$$OK
}
	
ClassMethod GetPet(pid As %Integer) As %Status
{
    Try {
        Do ##class(%REST.Impl).%SetContentType("application/json")
        If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
	        
		// Call implementation class
        Set response=##class(petapi.impl).GetPet(pid)
	        
		// Write implementation response as REST RESPOSE 
        Do ##class(%REST.Impl).%WriteResponse(response)
        
    } Catch (ex) {
        Do ##class(%REST.Impl).%SetStatusCode("400")
        return {"errormessage": "Client error"}
    }
    Quit $$$OK
}

}
```

### Implementation Class

```
Class petapi.impl Extends %CSP.REST
{
ClassMethod AddPet(body As %DynamicObject) As %DynamicObject
{
   Try{ 
    // Instantiate a new Pet object
    set pet = ##class(petapi.Pet).%New()
    // Read the JSON into the Pet object
    do pet.%JSONImport(body)
    // Save the object to the database
    set status = pet.%Save()
	   
    // Error handling
    if (status=1){
         return {"Response": "Object Saved to Database"}
         }
    else { 
        Do ##class(%REST.Impl).%SetStatusCode("500")
        return {"Response": "Error saving object "}
    }
   } Catch{
        Do ##class(%REST.Impl).%SetStatusCode("500")
        return {"errormessage": "Server error"}
   }
}
ClassMethod GetPet(pid As %Integer) As %DynamicObject
{
    Try{
        // Checks if ID exists
        if (##class(petapi.Pet).%ExistsId(pid))
            {
                // Opens the pet object at pet ID
                set pet = ##class(petapi.Pet).%OpenId(pid)
                
                // Exports the pet as JSON and returns it
                do pet.%JSONExport(.ret)
                return ret
            }
        // Error handling - id not found
        else { 
            Do ##class(%REST.Impl).%SetStatusCode("404")
            return {"errormessage": "Pet not found"}
        }
    // Error handling - general error
    } Catch (ex){
        Do ##class(%REST.Impl).%SetStatusCode("500")
        return {"errormessage": "Server error"}
    }
}
}
```

### Read More

- Documentation: [Introduction to Creating REST Services | Creating REST Services | InterSystems IRIS Data Platform 2025.2](https://docs.intersystems.com/iris20252/csp/docbook/DocBook.UI.Page.cls?KEY=GREST_intro)
- Article: [Developing REST API with a spec-first approach | InterSystems Developer](https://community.intersystems.com/post/developing-rest-api-spec-first-approach)
- Article: [Creating a REST service in IRIS | InterSystems Developer Community | REST](https://community.intersystems.com/post/creating-rest-service-iris)

### Learning 

- [Course: Setting Up RESTful Services - Learning | InterSystems](https://learning.intersystems.com/course/view.php?id=2549)
- [Video: REST API Design and Development - Learning | InterSystems](https://learning.intersystems.com/course/view.php?id=897)
- [Exercise: Developing REST Interfaces - Learning | InterSystems](https://learning.intersystems.com/course/view.php?id=2158)
- [Instruqt: REST + Angular App](https://play.instruqt.com/embed/intersystems/tracks/rest-angular?token=em__YNemOaCLyBswRCM)