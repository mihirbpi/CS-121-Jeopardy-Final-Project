"""
Student name(s): Mihir Borkar, Rupa Kurinchi Vendhan
Student email(s): mborkar@caltech.edu, rkurinch@caltech.edu

High-level program overview:
This program handles the client Python application of our Jeopardy! project.
This application allows a clien to log in and use the Jeopardy! application to get Jeopardy! stats.
******************************************************************************
"""
import sys  # to print error messages to sys.stderr
import mysql.connector
# To get error codes from the connector, useful for user-friendly
# error-handling
import mysql.connector.errorcode as errorcode

# Debugging flag to print errors when debugging that shouldn't be visible
# to an actual client. ***Set to False when done testing.***
DEBUG = False


# ----------------------------------------------------------------------
# SQL Utility Functions
# ----------------------------------------------------------------------
def get_conn():
    """"
    Returns a connected MySQL connector instance, if connection is successful.
    If unsuccessful, exits.
    """
    try:
        conn = mysql.connector.connect(
          host='localhost',
          user='jeopardyclient',
          # Find port in MAMP or MySQL Workbench GUI or with
          # SHOW VARIABLES WHERE variable_name LIKE 'port';
          port='3306',  # this may change!
          password='clientpw',
          database='jeopardydb' # replace this with your database name
        )
        print('Successfully connected.\n')
        return conn
    except mysql.connector.Error as err:
        # Remember that this is specific to _database_ users, not
        # application users. So is probably irrelevant to a client in your
        # simulated program. Their user information would be in a users table
        # specific to your database; hence the DEBUG use.
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR and DEBUG:
            sys.stderr('Incorrect username or password when connecting to DB.\n')
        elif err.errno == errorcode.ER_BAD_DB_ERROR and DEBUG:
            sys.stderr('Database does not exist.\n')
        elif DEBUG:
            sys.stderr(err)
        else:
            # A fine catchall client-facing message.
            sys.stderr('An error occurred, please contact the administrator.\n')
        sys.exit(1)

# ----------------------------------------------------------------------
# Functions for Command-Line Options/Query Execution
# ----------------------------------------------------------------------
def season_from_gameid(game_id):
    """"
    Gets the Jeopardy! game season from a Jeopardy! game id.
    Prints out relevant error messages if there's any issues.
    """
    cursor = conn.cursor()
    # Remember to pass arguments as a tuple like so to prevent SQL
    # injection.
    sql = 'SELECT game_to_season(\'%s\') AS s;' % (game_id)
    try:
        cursor.execute(sql)
        # row = cursor.fetchone()
        rows = cursor.fetchall()
        result = None
        for row in rows:
            (result) = (row) # tuple unpacking!
            # do stuff with row data
        if (not result[0]):
            print("That game id does not have a season associated with it\n")
        else:
            print("Season: " + str(result[0]) + "\n")
    except mysql.connector.Error as err:
        # If you're testing, it's helpful to see more details printed.
        if DEBUG:
            sys.stderr.write(err)
            sys.exit(1)
        else:
            sys.stderr.write('Please make sure you enter a valid INTEGER Jeopardy! game_id\n')


# ----------------------------------------------------------------------
# Functions for Logging Users In
# ----------------------------------------------------------------------
# Note: There's a distinction between database users (admin and client)
# and application users (e.g. members registered to a store). You can
# choose how to implement these depending on whether you have app.py or
# app-client.py vs. app-admin.py (in which case you don't need to
# support any prompt functionality to conditionally login to the sql database)
def authenticate_user(username, password):
    """"
    Authenticates a username and password when the user tries to login.
    Prints out relevant errors if the username/password is wrong.
    """
    cursor = conn.cursor()
    # Remember to pass arguments as a tuple like so to prevent SQL
    # injection.
    sql = 'SELECT authenticate(\'%s\', \'%s\');' % (username, password)
    try:
        cursor.execute(sql)
        # row = cursor.fetchone()
        rows = cursor.fetchall()
        login = None
        for row in rows:
            (login) = (row) # tuple unpacking!
            # do stuff with row data
        if(not login or not login[0]):
            print("Incorrect username and/or password\n")
            return False
        return True
    except mysql.connector.Error as err:
        # If you're testing, it's helpful to see more details printed.
        if DEBUG:
            sys.stderr.write(err)
            sys.exit(1)
        else:
            sys.stderr.write('An error occurred, please try again or contac an administrator.\n')
            return False
        
def login():
    """"
    Functionality to login a user by having them input
    a username and password.
    """
    username = input('Enter username: ')
    password = input('Enter password: ')
    return authenticate_user(username, password)
# ----------------------------------------------------------------------
# Command-Line Functionality
# ----------------------------------------------------------------------
def show_client_options():
    """
    Displays options client users can choose in the application.
    """
    print('What would you like to do? ')
    print('  (TODO: provide command-line options)')
    print('  (x) - something nifty to do')
    print('  (x) - another nifty thing')
    print('  (x) - yet another nifty thing')
    print('  (g) - Get the Jeopardy! game season from the Jeopardy! game id?')
    print('  (q) - Quit?')
    print()
    ans = input('Enter an option: ').lower()
    if ans == 'q':
        quit_ui()
    elif ans == 'g':
        game_id = input('Enter game id: ')
        season_from_gameid(game_id)

def quit_ui():
    """
    Quits the program, printing a good bye message to the user.
    """
    print('Good bye!')
    exit()

def main():
    """
    Main function for starting things up.
    If the user logs in successfully they can choose an option.
    Everytime a choice of option is selected and produces an output, the options are shown again and the process repeats until the user chooses the
    quit option.
    """
    if (login()):
        while(True):
            show_client_options()

if __name__ == '__main__':
    # This conn is a global object that other functions can access.
    # You'll need to use cursor = conn.cursor() each time you are
    # about to execute a query with cursor.execute(<sqlquery>)
    conn = get_conn()
    main()