# readme
This is our final project for CS 121 Relational Databases at Caltech.

Our project was working with a Jeopardy! database with information about 18 previous seasons.
The database includes information about the players (such as their name, occupation, and which
podium position they were in), information on questions from the games (question text and value),
and information on responses from the games (including who selected a question, who answered it,
its value, and how much was wagered). 

It includes an application which allows clients to
interact with this data through providing queries to get information on past Jeopardy!
seasons/players and an application which allows admins to submit requests to update our database with new contestants. 
Follow the instructions below to try it out for yourself. Thank you!

**Contributors:** Mihir Borkar and Rupa Kurinchi-Vendhan

**Data source:** 
https://github.com/anuparna/jeopardy/tree/master/dataset

**Instructions for loading data on command-line:**

Make sure you have MySQL downloaded and available through your
device's command-line. Also make sure you are in the folder containing all the project's
files.

First, create the following database in mySQL:
```
mysql> CREATE DATABASE jeopardydb;
mysql> USE jeopardydb;
```


Not including the "mysql>" prompt, run the following lines of code on your command-line
after creating and using an appropriate database:
```
mysql> source setup.sql;
mysql> source load-data.sql;
mysql> source setup-passwords.sql;
mysql> source setup-routines.sql;
mysql> source grant-permissions.sql;
mysql> source queries.sql;
```
**Instructions for Python program:**

Please install the Python MySQL Connector using pip3 if not installed already.
```
pip3 install mysql
pip3 install mysql-connector-python
pip3 install mysql-connector-python-rf
pip3 install mysqlclient
```

After loading the data and verifying you are in the correct database, 
run one of the following (not including the "mysql>" or "$") to open the Python application you want to use:

**Note:** app_admin.py has all the same features of app_client.py plus some additional ones, so
you may want to run app_admin.py first.
```
mysql> quit;

$ python3 app_client.py
```
OR
```
mysql> quit;
$ python3 app_admin.py
```

**Please log in with the following user/passwords:**

For app_client.py, the following admin/client users are registered:
Username  | Password     | Permissions
--------- | ------------ | -----------
Mihir     | iloveCS      | Admin       
Buford    | sqlinjection | Admin       
Rupa      | nopasswords  | Client      

For app_admin.py, the following admin users are registered:
Username  | Password     | Permissions 
--------- | ------------ | -----------
Mihir     | iloveCS      | Admin       
Buford    | sqlinjection | Admin       

Here is a suggested guide to using app_client.py:
    1.  Select option [a] to learn more about some products.
    2. Remember a product ID you want to buy!
    3. Select option [b] to purchase that item.
    4. Remember your purchase ID.
    5. Select option [d] to write a review using your purchase ID.
    6. Select option [c] to request a product.

Here is a suggested guide to using app_admin.py:
    1. Select option [a] to see which requests are unfulfilled.
    2. Remember a request ID you want to fulfill.
    3. Select option [b] to fulfill that request.
    4. Select option [c] to see how much money you've made!

Files written to user's system:
- No files are written to the user's system.

Unfinished features:
- Log appropriate employee ID in log (couldn't figure this one out, so it defaults to lorem).
- Rigorous checks to validate user input and actions (only basic checks are in place).
- Getting rid of redundant datasets/cleanup in general.
- Showing appropriate mySQL errors in the Python interface.
