# InterSystems-SQL Dialect

Structured Query Language (SQL) can be used to query IRIS databases in a relational way, however like all data platforms, InterSystems SQL has many unique syntactic points and features, some of which will be covered here. This guide will serve as an introduction to InterSystem-specific SQL functions, so is aimed at developers with some familiarity with basic SQL commands.

Its important to note that while data in IRIS can be accessed using SQL queries, the underlying data is stored in multi-dimensional hierarchical structures called Globals. As such, relational tables is one of many models the data can be accessed from.

Basic SQL syntax in IRIS conforms to the SQL-92 standard syntax and commands, meaning familiar commands can be used as expected, and migration to InterSystems is straightforward. 


### Functions 

#### Intrinsic functions
There are a wide range of functions that are provided either as an SQL standard, or as a IRIS-SQL intrinsic feature. These include: 

- Mathmatical functions, e.g.
    - `GREATEST`, `COS` (cosine), `TAN` (tangent), 
- Date functions e.g.:
    - `CURRENT_DATE`, `CURRENT_TIMESTAMP`, `DAY`, `DATEPART`, `DAYOFYEAR` 
- String Functions e.g.:
    - `$EXTRACT` - Extracts characters from string
    - `$FIND` - Returns position of a substring in a string.
    - `$TRANSLATE` – Performs character-for-character replacement.
    - `LOWER` - Returns Lower case version of string
- List Functions
    - `$LIST` - Returns elements in a list

There are also additional functions for Machine Learning and Vector search, these are explored in details on the pages [**LINK**]()


#### Defining Extrinsic Functions

You can define your own ObjectScript functions for SQL use: 
```sql
CREATE OR REPLACE FUNCTION HELLONAME(name VARCHAR)
 RETURNS VARCHAR
 LANGUAGE OBJECTSCRIPT
 {
    set str = "Hello World! your name is "_name
    Return str
 }
```
This can be used simply: 
```sql
SELECT name, HELLONAME(name) FROM Person
```
And outputs the following table:

|name|	Hello|
|---|-----------|
|Peter	|Hello World! your name is Peter|
|James	|Hello World! your name is James|
|Elizabeth	|Hello World! your name is Elizabeth|


Extrinsic functions can also be defined in Routine files as follows. 
```
MyFunc(name){
  SET x="Hello "_name_". Nice to meet you!"
  QUIT x
}
```

This function can then be called directly from SQL using the `$$` syntax, for example 
```
SELECT Name, $$MyFunc() FROM nametable  
```

### Text Search Features 


### Implicit Join Arrow Syntax

Classes in IRIS can have properties which are other classes. For example, company class might have a property `Address` which points to an `Address` class: 

```
Class packagename.Address Extends %SerialObject
{
    Property ZIP as %String;
}
```
```
Class packagename.Company Extends %Persistent{ 
    Property Name As %String;
    Property Address As Address; 
}

```

With this set-up, the Company table references the Address table. With standard SQL syntax, to access both the company name, a LEFT OUTER JOIN with a reference to the ID column that links the tables would be needed. This is simplified in IRIS-SQL with Arrow syntax for implicit joins: 

```sql
SELECT Name, Address -> ZIP As ZipCode 
FROM packagename.Company
```


