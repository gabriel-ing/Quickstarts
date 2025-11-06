# InterSystems SQL Dialect

Structured Query Language (SQL) can be used to query IRIS databases in a relational way, however like all data platforms, InterSystems SQL has many unique syntactic points and features, some of which will be covered here. This guide will serve as an introduction to InterSystem-specific SQL functions, so is aimed at developers who are familiar with standard SQL commands.

It's important to note that while data in IRIS can be accessed using SQL queries, the underlying data is stored in multi-dimensional hierarchical structures called Globals. As such, relational tables are one of many models the data can be accessed from.

Basic SQL syntax in IRIS conforms to the SQL-92 standard syntax and commands, meaning familiar commands can be used as expected, and migration to InterSystems is straightforward. 

## Standard SQL 

IRIS and InterSystems support ANSI Standard SQL operators and syntax, so fundamentally, one can expect any existing knowledge of SQL to  remain the same. Operators such as `SELECT`, `INSERT`, `UPDATE`, `JOIN`s, `GROUP BY`, `ORDER BY`, `WHERE`, et cetera, all work as standard. If you know SQL, you will feel at home. 

## Key InterSystems SQL Differences 

### Case Sensitivity
Identifiers and operators are not case sensitive in IRIS. Internally, all identifiers (table names and column names) are stored in upper-case. This means that the following queries all return the same results: 

```sql
SELECT NAME, AGE FROM SAMPLE.PERSON;
SELECT name, age FROM sample.person;
SeLeCT nAme, AgE FroM sAmPLE.peRSon;
select name, age from sample.person;
```
For readability, it's recommended to keep the operator keywords as uppercase, and the identifiers in lower-case or only the first letter capitalised.

### Single Quotes and Double Quotes (`''` vs `""`)

Double quotes `""` should be used for Identifiers, such as column or table names. Double quote delimeters are needed when an identifier contains a special character, e.g. a whitespace. 

```sql
SELECT "Column name" FRTOM "My Table"
```

Single quotes (`''`) should be used for Strings:

```sql
SELECT * FROM Sample.Person WHERE Name = 'Paul'
```
The use of double quotes for strings may cause errors due to the string being identified as an identifer.

### Pattern Matching 

There are additional operators in InterSystems SQL to allow for easier pattern matching in IRIS SQL. The `LIKE` operator still works, but there are also operators for `%STARTSWITH`, Contains (`[`) and `%MATCHES`. 

#### `%STARTSWITH`

The %STARTSWITH operator is use to test if a string starts with a substring:
```sql
SELECT Name, Age FROM Sample.Person WHERE Name %STARTSWITH 'P';
SELECT Name, Age FROM Sample.Person WHERE Name %STARTSWITH 'Pa';
```
This can also be used for numbers, for example:
```
SELECT Name, Age FROM Sample.Person WHERE Age %STARTSWITH 4;
```
returns all the people with ages of 4 or in their 40s. 

#### `[` Operator

The Operator `[` is used to test if the value contains the operand. For example, if a string contains a substring, or if a number contains another number. For example: 

```sql
SELECT Name, Age FROM Sample.Person WHERE Name [ 'u'
```
Selects all entries with a lower case 'u' in the name, and 

```sql
SELECT Name, Age FROM Sample.Person WHERE Age [ 2
```
Selects all entries with the digit 2 in the age: 

| Name     | Age |
|----------|-----|
|  Pamela  | 25  |
|  Jason   | 72  |

#### `%MATCHES`

The `%MATCHES` operator is a simple pattern matching tool. Patterns can be created using:
- `*` as a wildcard to match any number of characters (including zero)
- `?` as a wildcard to match a single character
- [abc] to match any one of the characters specified in brackets
- [^abc] to match any character except those in brackets
- [a-z], [0-9] to match a range of characters specified in brackets.

For example: 

```sql
-- Name Starts with P
SELECT Name, Age FROM Sample.Person WHERE Name %MATCHES 'P*'

-- Name contains "me" in the middle
SELECT Name, Age FROM Sample.Person WHERE Name %MATCHES 'me'

-- Name ends with a number 
SELECT Name, Age FROM Sample.Person WHERE Name %MATCHES '*[0-9]'
```

#### "%PATTERN"

You can create complex pattern matching using `%PATTERN`. This can be used if you have a code or value matching a specific format, like a social security number having the format 123-45-6789 could be matched with a pattern `3N-2N-4N`. The pattern syntax is given below:

| Pattern | Meaning                               |
| ------- | ------------------------------------- |
| `U`     | Uppercase letter (A–Z)                |
| `L`     | Lowercase letter (a–z)                |
| `A`     | Any alphabetic character (A–Z or a–z) |
| `N`     | Any numeric digit (0–9)               |
| `P`     | Any punctuation character             |
| `.`     | Any number of digits                  |
| `.E`    | Any number of any digit               |
| `1"N"`  | Exactly one literal 'N'               |
| `2L`    | Two lowercase letters                 |
| `3(AN)` | Three alphanumeric characters         |
| `""`    | Empty string                          |


```sql
-- Names that start with an uppercase letter followed by lowercase letters
SELECT Name FROM Sample.Person WHERE Name %PATTERN '1U.L';

-- Strings that are exactly three digits
SELECT Code FROM Sample.Table WHERE Code %PATTERN '3N';

-- Strings that are either a 5-digit ZIP or a 9-digit ZIP+4 code
SELECT ZIP FROM Sample.Address WHERE ZIP %PATTERN '5N,5N"-"4N';
```
### Table References and Implicit Join Arrow Syntax

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

With this set-up, the Company table references the Address table. With standard SQL syntax, to access both the company name, a LEFT OUTER JOIN with a reference to the ID column that links the tables would be needed. 

This is simplified in InterSystems SQL with Arrow syntax for implicit joins: 

```sql
SELECT Name, Address -> ZIP As ZipCode 
FROM packagename.Company
```

### String Concatenation

You can use `||` to concatenate strings. For example you can run: 

```sql
SELECT 'Hello '||Name As "Hello Name", Age FROM Sample.Person 
```
To return the following: 

| Hello Name    | Age |
|---------------|-----|
| Hello Paul    | 43  |
| Hello Jessica | 34  |
| Hello Stephen | 17  |

## Functions In InterSystems SQL
Functions in SQL are used to perform tasks using the data in table  as variables. There are four types of functions: 
- Intrinsic Functions 
    - Pre-defined functions built into IRIS that return a column of data, often this involves performing a task on every value of the column. 
- Extrinsic Functions 
    - Custom functions that return a column of data. 
- Aggregate Functions - functions that take column and output a single value for that column, e.g. `SUM`, `MIN`, `MAX`
- Window functions
    - Functions that are performed on a subset of data but return values to all rows. 
    - These  are Standard SQL so will not be covered in detail in this guide. See [Overview of Window Functions](https://docs.intersystems.com/iris20252/csp/docbook/DocBook.UI.Page.cls?KEY=RSQL_windowfunctions) for more detail.

### Intrinsic functions
IRIS SQL extends standard SQL with a set of intrinsic functions that provide capabilities not commonly found in other SQL dialects. These functions are particularly useful when working with IRIS-specific data structures and features.

#### List Functions
IRIS supports list structures as a native data type. Use these functions to manipulate lists:

- `$LIST` – Creates a list from elements
- `$LISTGET` – Retrieves an element by position
- `$LISTFIND` – Finds an element in a list

#### JSON functions
You can directly output data from SQL tables as JSON objects or arrays using: 
    - `JSON_OBJECT()`
    - `JSON_ARRAY()`
    - `JSON_TABLE()`

For example, 

```sql
SELECT JSON_OBJECT('Name': name, 'Age': Age) As JSON FROM Sample.Person
```
Outputs: 

|JSON|
|----|
|{"Name":"Paul","Age":"43"}|
|{"Name":"Jessica","Age":"34"}|
|{"Name":"Stephen","Age":"27"}|

#### String Functions (IRIS-specific)
Beyond standard SQL functions, IRIS provides powerful string manipulation tools:

- `$EXTRACT` – Extracts characters from a string
- `$FIND` – Returns the position of a substring
- `$TRANSLATE` – Performs character-for-character replacement

#### Specialized Functions
IRIS includes intrinsic functions for advanced features. For full details on these features, see the links to the relevant pages.

- [Machine Learning](linkMLPage) – Functions for model scoring and prediction
    - `PREDICT()`
    - `PROBABILITY()`
- [Vector Search](LinkVectorSearchPage) – Functions for similarity search on embeddings
    - `TO_VECTOR()`
    - `VECTOR_DOT_PRODUCT()`
    - `VECTOR_COSINE()`

For an extended list of intrinsic functions see [SQL Functions | Documentation](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=RSQL_FUNCTIONS).

### Defining Extrinsic Functions

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


#### Defining extrinsic Functions in ObjectScript

It is possible to define extrinsic functions directly in ObjectScript classes as follows: 

```
Class sample.mySqlFunctions extends %Persistent [ DdlAllowed ]
{
    ClassMethod GreetName(name As %String) As %String [ SqlProc ]
    {
            set output = "Hello "_name_" Nice to meet you"
            return output
    }
        ClassMethod AddTwo(age As %Integer) As %Integer [ SqlProc, SqlName=AddTwo ]
    {
            set newAge = age + 2
            return newAge
    }
}
```
To make a function runnable from SQL:
- The class extends `%Persistent` 
- The `[ DdlAllowed ]` allowed keyword needs to be added to the class definition
- The function needs to be a ClassMethod
- The `[ sqlproc ]` keyword needs to be added to the ClassMethod Definition
- You can define an SQL function name with the `[ sqlname = <FuncName> ]` keyword. This will override the default `<packagename>.<Classname>_<MethodName>` naming to create <packagename>.<FuncName>. 

These functions can then be called from SQL as follows: 
```sql
SELECT name, age,
sample.MySqlFunctions_Greetname(name), sample.AddTwo(age)
FROM sample.person
```
As the AddTwo function has an SQL name given as a keyword, the class name isn't in the function call. 

To give the following output: 

| Name     | Age | Expression_3                     | Expression_4 |
|----------|-----|----------------------------------|--------------|
| Paul     | 43  | Hello Paul Nice to meet you      | 45           |
| Jessica  | 34  | Hello Jessica Nice to meet you   | 36           |
| Stephen  | 17  | Hello Stephen Nice to meet you   | 19           |


### Aggregate Functions

Aggregate functions take a column of data and return a single aggregated value. Common examples include counting the number of rows (`COUNT`) and finding mathematical values like `SUM`, `MAX`, `AVG`, and `STDDEV`. 

Aggregate functions can also be used to return all the values in a column as comma-separated list (`LIST`), a concatenated string `XMLAGG`, or a JSON array (`JSON_ARRAYAGG`).

