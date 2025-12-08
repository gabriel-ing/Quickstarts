# Running SQL queries

SQL queries on the database can be run with the Python DB-API or with SQLAlchemy.

## DB-API

``` python
## Connection from above
connection = iris.connect(server, port, namespace, username, password)

cursor = connection.cursor() 

sql = "SELECT ID, Col1, Col2, Col3 FROM package.TableName"
cursor.execute(sql)

# Fetch next row
results_set = cursor.fetchone() 

# Fetch 5 rows
results_set = cursor.fetchmany(5)

# Fetch all (remaining) rows
results_set = cursor.fetchall() 

```

The results set is a list of lists, but can be easily converted to a pandas dataframe as follows:
``` python
import pandas as pd

df = pd.DataFrame(results_set, columns=["ID", "Col1", "Col2", "Col3"])
```

If you want to add parameter to a query at runtime, you can leave a ? in place of a parameter:

``` python
sql = "INSERT INTO package.TableName (ID, Col1, Col2, Col3) values (?,?,?,?)"

cursor.execute(sql, [1, "Hello", "World", "!"])
```

You can use similar syntax to execute many queries: 

``` python
sql = "INSERT INTO package.TableName (ID, Col1, Col2, Col3) values (?,?,?,?)"

params = [ 
	[1, "Hello", "World", "!"],
    [2, "Foo", "Bar", "Baz"],
    [3, "Alpha", "Beta", "Gamma"],
    [4, "One", "Two", "Three"]
]
cursor.executemany(sql, params)
```
### SQL alchemy

SQLAlchemy is a Python SQL client which is supported by InterSystems. It can be installed with 

```
pip install "sqlalchemy-iris[intersystems]"
```

This install the InterSystems-specific SQLAlchemy driver, as well as the normal SQLAlchemy as a dependency. It is used as follows: 

``` python
from sqlalchemy import create_engine 

# Credentials: 
username = "_system" 
password = "SYS" 
namespace = "USER" 
server = "localhost" 
port = 1972 

DATABASE_URL = f"iris://{username}:{password}@{server}:{port}/{namespace}" 

engine = create_engine(DATABASE_URL, echo=False)
```


You can use this engine to query directly with pandas to create a Pandas DataFrame: 

``` python
import pandas as pd 
query = "SELECT ID, Col1, Col2, Col3 FROM package.TableName"

df = pd.read_sql(query, engine)

df.head()
```

You can also SQLAlchemy to create a table:

``` python
from sqlalchemy import Column, MetaData, Table, select
from sqlalchemy.sql.sqltypes import Integer, VARCHAR
from sqlalchemy_iris import IRISVector

## Create a table, adding column objects to create the schema

demo_table = Table("demoTableName",  ## Give the table a name
                    
                    ## Create metadata for the table
                    MetaData(), 
                    
                    ## Create an ID as the index and autoincrement it
                    Column("ID", Integer, primary_key=True, autoincrement = True),
                    
                    ## Create a column for the item name
                    Column("Name", VARCHAR(1024)),
                    
                    ## Use the special IRIS Vector datatype to embed vectors 
                    Column("EmbeddingVectors", IRISVector(item_type=float, max_items=3)) 
                  )
```

and insert data: 
``` python
with engine.connect() as conn: 
    conn.execute( demo_table.insert(), ## the action being executed
                [
                    {"Name": "Cat","EmbeddingVectors":[4,4,2]},
                    {"Name": "Dog","EmbeddingVectors":[3.5,3.5,2]},
                    {"Name": "Espresso", "EmbeddingVectors":[-2, -2, 1]},
                    {"Name": "Tea", "EmbeddingVectors":[-1, -5, 0]}
                ]
    )
    conn.commit()
```