Class SQL.SqlFunction Extends %RegisteredObject [ DdlAllowed, Not ProcedureBlock ]
{

/// Description
ClassMethod GreetName(name As %Library.String(MAXLEN=50)) As %Library.String(MAXLEN=50) [ Language = objectscript, SqlName = GREETNAME, SqlProc ]
{
        Return "Hello "_name_" Nice to meet you"
}

}
