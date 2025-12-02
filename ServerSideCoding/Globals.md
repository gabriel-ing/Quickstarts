## Globals

Globals are the storage structure at the heart of InterSystems IRIS. These are hierarchical multi-dimensional arrays where each node of the hierarchical tree structure has a key, or subscript and a value. Globals are denoted by a caret `^`, e.g. `^GlobalName`.

Nodes can be referenced, or values set by listing out the subscripts, so `^GlobalName(sub1, sub2, ...)`

```
set ^Demo(1,2,"position") = 4
set ^Demo(1) = "Hello"
set ^Demo(5) = "World"
```

Would create the following global: 

```
          ^Demo
        /       \
      /          5 : "World"
	1 : "Hello"
	|
	2 :
	|
position: 4
```

Subscripts and values can be any type. If you create a SQL table in InterSystems IRIS, it will be stored as a global, with each row being stored under a different index ID.

For a detailed explanation of globals, see: [Video: What Are Globals? | Youtube](https://www.youtube.com/watch?v=jJifoZq2bW0)

