# readme

**Contributors:** **Mihir Borkar** and **Rupa Kurinchi-Vendhan**

**Introduction:**

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


**Data source:** 
https://github.com/anuparna/jeopardy/tree/master/dataset



**Instructions for loading data on command-line:**

Make sure you have MySQL downloaded and available through your
device's command-line. Also make sure you are in the folder containing all the project's
files.

First, open MySQL on the command line and create the following database in mySQL:
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
mysql> quit;
```

**Instructions for Python programs:**

Please install the Python MySQL Connector using pip3 with the following commands (not including the "$"), if not installed already.
```
$ pip3 install mysql
$ pip3 install mysql-connector-python
$ pip3 install mysql-connector-python-rf
$ pip3 install mysqlclient
```

After loading the data and verifying you are in the correct database, 
run one of the following (not including the "$") to open the Python application you want to use:
```
$ python3 app_admin.py
```
OR
```
$ python3 app_client.py
```

**Note:** Details on how to use each Python app are further below. ```app_admin.py``` has all the same features of ```app_client.py``` plus some additional ones, so
you may want to run ```app_admin.py``` first.

**The following are the usernames/passwords to use for the Python apps:**

For ```app_admin.py```, the following admin/client users are registered:
Username  | Password                 |  Permissions
--------- | -------------------------| ------------------------
```Mihir```     | ```iloveCS```      | Admin       
```Buford```    | ```sqlinjection``` | Admin       

For ```app_client.py```, the following admin/client users are registered:
Username  | Password                 |  Permissions
--------- | -------------------------| ------------------------
```Mihir```     | ```iloveCS```      | Admin       
```Buford```    | ```sqlinjection``` | Admin       
```Rupa```      | ```nopasswords```  | Client      


**Here is a suggested guide to using ```app_admin.py```:**
    
1. Login with the username ```Mihir``` and the corresponding password.
    
2. Select option ```(s)```, follow the instructions that are printed, and enter the season number ```25``` to get the total winnings over that season.
    
3. Select option ```(t)```, follow the instructions that are printed, and enter the player name ```Ken Jennings``` to get Ken Jennings' total winnings.
    
4. Select option ```(c)```, follow the instruction that are printed, and enter the information for a new contestant with the player_id ```113011```.
    
5. Select option ```(c)``` again, follow the instructions that are printed, and enter the information for another, different new contestant with the player_id ```113012```.
    
6. Select option ```(q)``` to quit the application.
    
7. Run ```$ python3 app_admin.py``` (without the "$") in the command line again to reopen the application.
    
8. Try to login with the client username ```Rupa``` and the corresponding password.
    
9. Run ```$ python3 app_admin.py``` (without the "$") in the command line again to reopen the application.
    
10. Login with the username ```Buford``` and the corresponding password.
    
11. Select option ```(c)``` again, follow the instructions that are printed, and enter the information for another, different new contestant with the player_id ```113013```.
    
12.  Select option ```(q)``` to quit the application.
    
13. Open MySQL on the command line and perform the following commands (without the "mysql>" prompt):
    ```
    mysql> USE jeopardydb;
    mysql> SELECT * FROM contestants WHERE player_id > 113010;
    ```
    You should see the information for the new contestants you entered displayed on the screen in a table.
        
    Next, perform the following commands (without the "mysql>" prompt): 
    ```
    mysql> SELECT * FROM contestant_changes;
    mysql> SELECT * FROM update_stats;
    ```
    You should see the timestamps of when the admin users ```Mihir``` and ```Buford``` updated the contestants,
    as well as how many times each user updated the contestants displayed on the screen in two tables.
    
        
**Here is a suggested guide to using ```app_client.py```:**
1. Login with the username ```Rupa``` and the corresponding password.
    
2. Select option ```(s)```, follow the instructions that are printed, and enter the season number ```25``` to get the total winnings over that season.
    
3. Select option ```(t)```, follow the instructions that are printed, and enter the player name ```Ken Jennings``` to get Ken Jennings' total winnings.
    
4. Select option ```(q)``` to quit the application.


**Files written to user's system:**
- No files are written to the user's system.


**Unfinished features:**
- Rigorous checks to validate user input and actions (only basic checks are in place).
