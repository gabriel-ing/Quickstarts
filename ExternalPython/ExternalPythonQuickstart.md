# Connecting to InterSystems IRIS from Client-Side Python Applications 

Much of the functionality of InterSystems IRIS can be accessed from Python programs that run externally to the InterSystems IRIS instance. This is distinct from Embedded Python, which exists with classes and is run within InterSystems IRIS.

This guide refers to connecting to instances of InterSystems IRIS using applications run on the client-side, i.e. not on the same server as InterSystems IRIS. This connection can be made to allow access to InterSystems IRIS databases, or to run scripts or functions on the InterSystems IRIS server. 

## Installing the Python Software Development Kit

The SDK can be installed using pip: 

```sh
pip install intersystems-irispython
```

You can then connect to IRIS as follows: 

``` python
import iris

server = "localhost"
port = 1972 
namespace = "USER"
username = "_system"
password = "SYS"

connection = iris.connect(server, port, namespace, username, password)
```

From the connection object, you can either create a `irispy` object to access globals and server-side methods, or create a `cursor` object to run SQL queries on a database with the DB-API. 

### Further Reading
- [Orientation for Python Developers | Orientation for Python Developers | InterSystems IRIS Data Platform](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GPYDEV_journey)
- [Introduction to the Native SDK for Python | Using the Native SDK for Python | InterSystems IRIS Data Platform ](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=BPYNAT_about)
