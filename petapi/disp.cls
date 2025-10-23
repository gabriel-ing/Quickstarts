Class petapi.disp Extends %CSP.REST
{

/// Handle Cors Request info
Parameter HandleCorsRequest = 1;

/// Define the REST Routes in XML format
/// Route URL is the endpoint location being queried 
/// Method is the HTTP method used to query
/// Call is the function that is called
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
        
        Set response=##class(petapi.impl).AddPet(%request.Content.Read())

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
        

        Set response=##class(petapi.impl).GetPet(pid)

        Do ##class(%REST.Impl).%WriteResponse(response)

    } Catch (ex) {
        Do ##class(%REST.Impl).%SetStatusCode("400")
        return {"errormessage": "Client error"}
    }
    Quit $$$OK
}

}
