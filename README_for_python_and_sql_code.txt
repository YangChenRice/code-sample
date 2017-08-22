COMP 533 Project: A python application which calls functions in PostgresSQL to accomplish various database manipulation tasks 

1.Run the .sql code in psql. The database is 'postgres', and the username is 'ricedb', server is 'localhost'.
2.Run the python code. In the python code, I have defined a series of functions. After that, I employ them to accomplish various database manipulation tasks.
3.My insert functions are actually upsert functions. So when you enter a tuple which conflicts with other tuples in primary key, the record will be updated.