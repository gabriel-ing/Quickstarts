# Vector Search Quickstart

Vector search is fundamental to many modern AI and machine learning techniques. Unstrutured data can be embedded into a vector position on a multi-dimensional plane, with the resulting position representing their semantic meaning. Data with the similar semantic meaning have vectors which are close to each other. Vector searches therefore can be used to quickly retrieve related information based on semantic meaning. 

InterSystems IRIS has built in features for Vector search within the SQL dialect with the introduction of VECTOR and EMBEDDING data types.
- VECTOR is for data already in vector format
- EMBEDDING is used to convert an existing column to vectors, this requires configuration. 

For complete documentation, see: [Vector Search Documentation](https://docs.intersystems.com/irislatest/csp/docbook/Doc.View.cls?KEY=GSQL_vecsearch#GSQL_vecsearch_index).

## IRIS Vector Search keywords

### VECTOR
SQL datatype. It is defined with a type for each dimension, usually a numeric type like DOUBLE, and a number of dimensions. The number of dimensions will depend on the embedding model used. 

Usage: 
```sql
CREATE TABLE VectorStore ( Sentence VARCHAR(200), SentenceVector VECTOR(DOUBLE, 384))
```

### TO_VECTOR() 

SQL Function to convert a vector represented as a string (e.g. "[1, 2, 3]") to a SQL VECTOR datatype.

Usage: 
```sql
INSERT INTO VectorStore (Sentence, SentenceVector) ("Hello World", TO_VECTOR("[1,2,3]"))
```

### EMBEDDING 

SQL Datatype for automatic embedding of another data column to vectors. Requires creating embedding configuration with %Embedding.Config (see below). Takes two arguments on column creation, - the name of the embedding configuration being used and the table column to be embedded.

**Usage:** 
```sql
CREATE TABLE EmbeddingStore (Sentence VARCHAR(200), SentenceEmbedding EMBEDDING("my-embedding-config", "Sentence"))
```

### VECTOR_DOT_PRODUCT()

Function to calculate the distance between vectors, measuring both magnitude and direction of the vector. Commonly used to order results to find the most similra 

**Usage:** 
VECTOR Type: 
```sql
SELECT TOP 5 Sentence FROM VectorStore
  ORDER BY VECTOR_DOT_PRODUCT(SentenceVector, 
                              TO_VECTOR("[0.1 ... 0.3]")) DESC
```

Embedding Type: 
```sql
SELECT TOP 5 Sentence FROM EmbeddingStore
  ORDER BY VECTOR_DOT_PRODUCT(SentenceEmbedding, 
                              EMBEDDING(?)) DESC
```
### VECTOR_COSINE()
Function to calculate the angle between vectors. This ignores the magnitude of the vector, which may be important if the vectors are not normalised or if you have very variable sentence lengths.  

**Usage:**

VECTOR Type: 
```sql
SELECT TOP 5 Sentence FROM VectorStore
  ORDER BY VECTOR_COSINE(SentenceVector, 
                              TO_VECTOR("[0.1 ... 0.3]")) DESC
```
Embedding Type: 
```sql
SELECT TOP 5 Sentence FROM EmbeddingStore
  ORDER BY VECTOR_COSINE(SentenceEmbedding, 
                        EMBEDDING("Birds Fly High")) DESC
```
#### %EmbeddingConfig

Table containing the embedding configurations for use with Embedded datatype. To create a new config, insert a row with:  
- *config name*
- *Configuration* (JSON Formatted string), 
- *Embedding class*  
- *Vector Length*
- *Description*

For full details, see the [documentation](https://docs.intersystems.com/iris20252/csp/docbook/Doc.View.cls?KEY=GSQL_vecsearch#GSQL_vecsearch_insembed).

**Usage:** 
```sql
INSERT INTO %Embedding.Config (Name, Configuration, EmbeddingClass, VectorLength, Description)
  VALUES ('my-openai-config', 
          '{"apiKey":"<api key>", 
            "sslConfig": "llm_ssl", 
            "modelName": "text-embedding-3-small"}',
          '%Embedding.OpenAI', 
          1536,  
          'a small embedding model provided by OpenAI') 
```

### INDEX

A column type used (in this context) to improve vector search efficiency by pre-calculating distances in VECTOR or EMBEDDING columns. Algorithms used include Approximate Nearest Neighbour (ANN) and Heirarchical Navigable Small World (HNSW).

**Usage:**
```sql
CREATE INDEX HNSWIndex ON TABLE VectorStore (SentenceVector)
  AS HNSW(Distance='Cosine')
```


## Complete Example
This quickstart will cover using the VECTOR datatype from external Python application connected via the DB-API.. Vector embeddings are created with the [sentence transformers library](https://www.sbert.net/). 

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
create_table_query= """ CREATE TABLE VectorStore (
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

# Generate embeddings for all descriptions at once. 
embeddings = model.encode(sentences, normalize_embeddings=True)

embeddings_string_list = [str(x) for x in embeddings.tolist()]
```

#### Add vectors to IRIS table

```python
sql_insert = "INSERT INTO VectorStore (Sentence, SentenceVector), (? TO_VECTOR(?))"
cursor.executemany(sql_insert, embedding_string_list)
```

#### Perform search

```python
# Query to search
query = "Green tea contains antioxidants" 

# Embed query to vector using same model
query_vector = model.encode(query, normalize_embeddings=True).tolist()

# Create query
query_sql = """SELECT TOP 1 Sentence 
                FROM VectorStore
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