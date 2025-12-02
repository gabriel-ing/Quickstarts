
# Calling SQL Statements

Structured Query Language, or SQL is used to interact with InterSystems IRIS Database through a relational model, that is treating the values stored in globals as data tables. You can call SQL statements from many different places, allowing the flexibility to use the data in a relational format, whatever your application or use case.

## Management Portal SQL Editor
The easiest way to use SQL with your dataset is within the Management Portal at http://localhost:52773/csp/sys/exp/%25CSP.UI.Portal.SQL.Home.zen (remember to change the server and port to match your IRIS instance). 

To find the SQL Editor from the homepage, select `System Explorer` from the left-hand panel, then select `SQL` and click `GO`. 

You can change the namespace from the link at the top of the page (Orange box in image below).  

![SQL Editor in the Management Portal](SQL-Editor.png)

To run a SQL Statement, type the statement into the editor box and click `Execute` or press `Ctrl-Enter`. 

There are too many features within the management portal to demo them all, so to find out more, its recommended to look at the [relevant page of the documentation](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GSQL_smp). 

Some useful features for beginners: 
  - You can navigate the tables in your namespace with the panel on the right-hand side.

  - Click and drag any table from this list to the command box, to automatically generate a query to select all the data from the table.
  
![Drag to create Select Query](Drag-For-Table-Query.gif)

  - Create Select Queries using a graphical user interface with the `Query Builder` button.

  - See the previous commands run by clicking `Show History` - from here you can find your previous queries, and execute them directly. 

## Terminal

You can start a SQL terminal shell from an IRIS terminal with: 

```
do ##class(%SYS.SQL).Shell()
```
or as a shortcut:
```
:sql
```
From here, you can run SQL statements and queries. 

```
USER>:sql
SQL Command Line Shell
----------------------------------------------------

The command prefix is currently set to: <<nothing>>.
Enter <command>, 'q' to quit, '?' for help.
[SQL]USER>>SELECT * FROM NAME
```

To return to the IRIS terminal, simply run `quit`.



## External Connections

You can connect to IRIS databases using SQL from a number of external applications. 

There are standard drivers for Java Database Connectivity (JDBC) and Open Database Connectivity (ODBC). These drivers can be used for connections from a range of languages, which are covered separately on the [External Languages page](Link needed!), and many applications that support these connection types, including the database explorer DBeaver, analytics tools like PowerBI and Tableau, ETL or integration platforms such as Talend and Informatica.

### JDBC 
JDBC is a database connection standard that is used within Java applications. To connect to IRIS using JDBC, use the following syntax to create a URL. 

```
jdbc:IRIS://<host>:<port>/<namespace>
```
- _Host_ is the Server location, if running locally this is `localhost` or `127.0.0.1`
- _port_ is the TCP port number for binary connections, the default is `1972`
- _Namespace_ is the namespace containing the data tables.

A basic example of a connection string to a locally running IRIS instance is:
```
jdbc:IRIS://localhost:1972/USER
```
#### DBeaver

Connections to IRIS are natively supported within the database client application [DBeaver](https://openexchange.intersystems.com/package/DBeaver). The connection can be done with the JDBC connection string above. For more information, see [DBeaver officially supports InterSystems IRIS](https://community.intersystems.com/post/dbeaver-officially-supports-intersystems-iris).

### ODBC

InterSystems supports connections with ODBC. The nature of these connections depends on the operating system and environment you are using it from, so for full details on installation and set-up, see the [relevant documentation pages](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=BNETODBC_intro). 

Setting up an ODBC connection as a data-source allows you to use the data directly in applications on your system, including using it directly within Excel. 

There are also open source libraries for connection to ODBC using Node.JS and other external languages, allowing for relational table access from JavaScript. 

### Python DB-API 

There is a specific driver for database connections with python, this is covered in detail on the [External Languages - Python](../ExternalPython/External%20Python%20Quickstart.md) page. 