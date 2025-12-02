# Vector Search Quickstart

Vector search is fundamental to many modern AI and machine learning techniques. Unstrutured data can be embedded into a vector position on a multi-dimensional space, with the resulting position representing the data's semantic meaning. Data points with similar semantic meanings have vectors which are close to each other in the space. Vector searches can therefore be used to quickly retrieve relevant information based on the semantic meaning of the search query. 

InterSystems IRIS has built in vector search capabilities within the SQL dialect, supporting both VECTOR and EMBEDDING data types.
- VECTOR is for data already converted to vector format
- EMBEDDING is used to convert an existing column to vectors within IRIS (this requires configuration) 

This guide will focus on the use of the VECTOR data type, and the insertion of already generated vectors.

For complete documentation, see: [Vector Search Documentation](https://docs.intersystems.com/irislatest/csp/docbook/Doc.View.cls?KEY=GSQL_vecsearch#GSQL_vecsearch_index).

## Vector Search Steps

The steps to performing a vector search in InterSystems IRIS are: 
1. Create Vectors with an Embedding model
2. Insert Vectors into a table with the VECTOR datatype 
3. Convert query prompt to a vector 
4. Query the database using VECTOR_COSINE() or VECTOR_DOT_PRODUCT() to order the data

## Walkthrough

As Python is the primary language used for Embedding Models, Transformers and AI generally, this example is written in client-side Python code, connecting to InterSystems IRIS with the Python DB-API. However, the process would be similar and involve the same SQL commands for other coding languages or server-side embedded Python. 

Vector embeddings are created with the [sentence transformers library](https://www.sbert.net/). 

#### Install dependancies: 

```bash
pip install intersystems-irispython
pip install sentence-transformers
```
#### Connect to IRIS:

```python
import iris 

# Server configuration
server = "localhost"
port = 1972
namespace = "USER"
username = "_SYSTEM"
password = "SYS"

# Create Connection
connection = iris.connect(server, port, namespace, username, password)

# Created DB-API Cursor
cursor = connection.cursor()
```

#### Create new SQL table:

Here were are defining a new table containing a sentence, and the corresponding Vectors. We define the VECTOR data type, with each vector having 384 dimensions made up of the DOUBLE floating point number data type.

```python
create_table_query= """ CREATE TABLE Sample.VectorStore (
    Sentence VARCHAR(200), 
    SentenceVector VECTOR(DOUBLE, 384)
)
"""
cursor.execute(create_table_query)
```

#### Create vectors:

```python
from sentence_transformers import SentenceTransformer

sentences = [
    "The quick brown fox jumps over the lazy dog.",
    "Artificial intelligence is transforming the way we interact with technology.",
    "A cup of coffee in the morning helps me focus better at work.",
    "The Eiffel Tower is one of the most iconic landmarks in Paris."
]

# Load a pre-trained sentence transformer model. 
model = SentenceTransformer('all-MiniLM-L6-v2') 

# Generate embeddings for all descriptions at once and return them as a list
embeddings = model.encode(sentences, normalize_embeddings=True).tolist()

```

#### Add vectors to IRIS table

```python
# Create the SQL Insert Command using ? as placeholders fov values
sql_insert = "INSERT INTO Sample.VectorStore (Sentence, SentenceVector) VALUES (?, TO_VECTOR(?))"

# Insert each sentence and corresponding vector
for x in range(len(sentences)):
    cursor.execute(sql_insert, [sentences[x], str(embeddings[x])])
```

#### Perform search

```python
# Query to search
query = "Green tea contains antioxidants" 

# Embed query to vector using same model
query_vector = model.encode(query, normalize_embeddings=True).tolist()

# Create query
query_sql = """SELECT TOP 1 Sentence 
                FROM Sample.VectorStore
                ORDER BY VECTOR_DOT_PRODUCT(SentenceVector, TO_VECTOR(?, DOUBLE)) DESC"""

# Execute sql passing in the query vector as a string
cursor.execute(query_sql, [str(query_vector)])
results = cursor.fetchall()
print(results)
```
Output:
```
(('A cup of coffee in the morning helps me focus better at work.',),)
```
As one might expect, the sentence most similar to a query about Green tea is one about coffee. So there we have it, a simple vector search set-up, performed with InterSystems IRIS!


## Indexing 
The efficiency of InterSystems IRIS Vector Search is improved by an Approximate Nearest Neighbor index, meaning not every vector calculation needs to be performed, and instead an approximation limits the search to only the vectors close to the query vector. While this means the results are not guarenteed to be completely accurate, it can provide a huge performance benefit for large datasets. 

Indexes are created automatically upon insertion. For large datasets, this can dramatically slow down the rate of insertion, so it can be beneficial to turn off the automated indexing, and instead manually create an index after insertion. 

To separate insertion and indexing, use the %NOINDEX keyword when inserting (or updating a row): 

```
INSERT %NOINDEX INTO Sample.VectorStore (Sentence, SentenceVector) VALUES ("The quick brown fox", TO_VECTOR("[0.2, 0.1, ....]"))
```
or
```
UPDATE %NOINDEX Sample.VectorStore SET SentenceVector = TO_VECTOR("[0.2, 0.1, ....]") WHERE ID = rowID
```

After insertion, the index can be created using: 

```
CREATE INDEX HNSWIndex ON TABLE Sample.VectorStore (SentenceVector) AS HNSW(Distance="Cosine")
``` 

With small datasets, it is likely faster to insert with automatic indexing, and it is possible that the automatic SQL optimiser in InterSystems IRIS will result in the index not being used. 

## Cosine Vs Dot Prodct

When comparing the similarity of Vectors, there is a choice between using VECTOR_COSINE() and VECTOR_DOT_PRODUCT(). The practical difference between these is that VECTOR_COSINE measures the angle between the vectors only, while the dot product combines both direction and magnitude of the vectors. As such, the dot product will also be sensitive to the size of the vector. Dot product therefore could be useful to perform the calculation weighted by strength. 

In many cases (including the example above), the vectors are normalised, meaning the vector magnitude is constant. In these cases, both functions are likely to yield similar results, with the cosine being sufficient for most uses.  