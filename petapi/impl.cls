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
