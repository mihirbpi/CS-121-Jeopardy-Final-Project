"""
Student name(s): Mihir Borkar, Rupa Kurinchi Vendhan
Student email(s): mborkar@caltech.edu, rkurinch@caltech.edu

High-level program overview:
This program handles the admin Python application of our Jeopardy! project.
This application allows an admin to log in and use the Jeopardy! application 
to get Jeopardy! stats or insert new contestant information into the database.
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
# Variable to store username when logged in
user = None


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
          user='jeopardyadmin',
          # Find port in MAMP or MySQL Workbench GUI or with
          # SHOW VARIABLES WHERE variable_name LIKE 'port';
          port='3306',  # this may change!
          password='adminpw',
          database='jeopardydb',
          auth_plugin='mysql_native_password'
        )
        print('Successfully connected.\n')
        return conn
    except mysql.connector.Error as err:
        # Remember that this is specific to _database_ users, not
        # application users. So is probably irrelevant to a client in your
        # simulated program. Their user information would be in a users table
        # specific to your database; hence the DEBUG use.
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR and DEBUG:
            sys.stderr.write('Incorrect username or password when connecting to DB.\n')
        elif err.errno == errorcode.ER_BAD_DB_ERROR and DEBUG:
            sys.stderr.write('Database does not exist.\n')
        elif DEBUG:
            sys.stderr.write(str(err))
        else:
            # A fine catchall client-facing message.
            sys.stderr.write('An error occurred, please contact the administrator.\n')
        sys.exit(1)

# ----------------------------------------------------------------------
# Functions for Command-Line Options/Query Execution
# ----------------------------------------------------------------------
def avg_player_winnings(player_name):
    """"
    Gets the average winnings of a player from seasons 16-33 of Jeopardy.
    Prints out relevant error messages if there's any issues.
    """
    cursor = conn.cursor()
    # Remember to pass arguments as a tuple like so to prevent SQL
    # injection.
    sql = 'SELECT avg_player_winnings(\'%s\');' % (player_name)
    try:
        cursor.execute(sql)
        # row = cursor.fetchone()
        rows = cursor.fetchall()
        result = None
        for row in rows:
            (result) = (row) # tuple unpacking!
            # do stuff with row data
        if (not result or not result[0]):
            print('That player does not have any winnings associated with them\n')
        else:
            print("Avg winnings: " + str(result[0]) + "\n")
    except mysql.connector.Error as err:
        # If you're testing, it's helpful to see more details printed.
        if DEBUG:
            sys.stderr.write(str(err))
            sys.exit(1)
        else:
            sys.stderr.write('Please make sure you enter a valid Jeopardy! player name (capitalized first_name, followed by a space, followed by capitalized last_name) or contact the administrator\n')

def total_player_winnings(player_name):
    """"
    Gets the total winnings of a player from seasons 16-33 of Jeopardy.
    Prints out relevant error messages if there's any issues.
    """
    cursor = conn.cursor()
    # Remember to pass arguments as a tuple like so to prevent SQL
    # injection.
    sql = 'SELECT total_player_winnings(\'%s\');' % (player_name)
    try:
        cursor.execute(sql)
        # row = cursor.fetchone()
        rows = cursor.fetchall()
        result = None
        for row in rows:
            (result) = (row) # tuple unpacking!
            # do stuff with row data
        if (not result or not result[0]):
            print('That player does not have any winnings associated with them\n')
        else:
            print("Total winnings: " + str(result[0]) + "\n")
    except mysql.connector.Error as err:
        # If you're testing, it's helpful to see more details printed.
        if DEBUG:
            sys.stderr.write(str(err))
            sys.exit(1)
        else:
            sys.stderr.write('Please make sure you enter a valid Jeopardy! player name (capitalized first_name, followed by a space, followed by capitalized last_name) or contact the administrator\n')

def total_season_winnings(season_number):
    """"
    Gets the total winnings from Jeopardy! game season (16-33)
    Prints out relevant error messages if there's any issues.
    """
    cursor = conn.cursor()
    # Remember to pass arguments as a tuple like so to prevent SQL
    # injection.
    sql = 'SELECT total_season_winnings(\'%s\');' % (season_number)
    try:
        cursor.execute(sql)
        # row = cursor.fetchone()
        rows = cursor.fetchall()
        result = None
        for row in rows:
            (result) = (row) # tuple unpacking!
            # do stuff with row data
        if (not result or not result[0]):
            print('That season does not have any winnings associated with it\n')
        else:
            print("Total season winnings: " + str(result[0]) + "\n")
    except mysql.connector.Error as err:
        # If you're testing, it's helpful to see more details printed.
        if DEBUG:
            sys.stderr.write(str(err))
            sys.exit(1)
        else:
            sys.stderr.write('Please make sure you enter a valid INTEGER Jeopardy! season (16-33) or contact the administrator\n')

def add_new_contestant(player_id, first_name, last_name, city, state, 
                       occupation):
    """"
    Adds a new contestant to the database given their information
    Prints out relevant error messages if there's any issues.
    """
    if (first_name == '' or last_name == ''):
        first_name = None
        last_name  = None

    global user
    cursor = conn.cursor()
    try:
        args = [int(player_id), first_name, last_name, city, state, 
                occupation]
        result = cursor.callproc('sp_add_contestant', args)
        conn.commit()
        result = cursor.callproc('contestant_change', [user])
        conn.commit()
    except ValueError or mysql.connector.Error as err:
        # If you're testing, it's helpful to see more details printed.
        if DEBUG:
            sys.stderr.write(str(err))
            sys.exit(1)
        else:
            sys.stderr.write('Please make sure you enter a valid INTEGER player_id that does not already exist. Also the player\'s first name and last name are required fields.\n')
    except mysql.connector.IntegrityError as err:
        # If you're testing, it's helpful to see more details printed.
        if DEBUG:
            sys.stderr.write(str(err))
            sys.exit(1)
        else:
            sys.stderr.write('Please make sure you enter a valid INTEGER player_id that does not already exist. Also the player\'s first name and last name are required fields.\n')

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
    Prints out relevant errors if the username/password is wrong or if the 
    username and password is right but the user does not have the right 
    permissions.
    """
    global user
    cursor = conn.cursor()
    # Remember to pass arguments as a tuple like so to prevent SQL
    # injection.
    sql = 'SELECT authenticate(\'%s\', \'%s\') AS login, is_admin FROM user_info WHERE username=\'%s\';' % (username, password, username)
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
        if (not login[1]):
            print("Error: You are not an admin user\n")
            return False
        user = username
        return True
    except mysql.connector.Error as err:
        # If you're testing, it's helpful to see more details printed.
        if DEBUG:
            sys.stderr.write(str(err))
            sys.exit(1)
        else:
            sys.stderr.write('An error occurred, please try again or contact an administrator.\n')
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
def show_admin_options():
    """
    Displays options admin users can choose in the application.
    """
    print()
    print('What would you like to do? ')
    print('  (c) - Add a new contestant to the database?')
    print('  (s) - Get total Jeopardy! winnings over a season?')
    print('  (t) - Get total Jeopardy! winnings of a player?')
    print('  (a) - Get average Jeopardy! winnings of a player?')
    print('  (q) - Quit?')
    print()
    ans = input('Enter an option: ').lower()
    if ans == 'q':
        quit_ui()
    elif ans == 'a':
        print('This option returns the average Jeopardy! winnings of a player over seasons 16-33')
        print('Enter player_name as capitalized first_name, followed by a space, followed by capitalized last_name')
        print('For example: Ken Jennings')
        player_name = input('Enter player_name: ')
        avg_player_winnings(player_name)
    elif ans == 't':
        print('This option returns the total Jeopardy! winnings of a player over seasons 16-33')
        print('Enter player_name as capitalized first_name, followed by a space, followed by capitalized last_name')
        print('For example: Ken Jennings')
        player_name = input('Enter player_name: ')
        total_player_winnings(player_name)
    elif ans == 's':
        print('This option returns the total winnings over an an entire  Jeopardy! season (only supports seasons 16-33)')
        print('Enter a season number (an integer 16-33)')
        print('For example: 25')
        season_number = input('Enter season number: ')
        total_season_winnings(season_number)
    elif ans == 'c':
        print('This option allows you to add a new contestant to the database')
        print('Enter an INTEGER player_id that does not already exist')
        print('For example: 113011 or higher')
        print('Also please enter the player first name and last name when prompted')
        player_id = input('Enter player_id: ')
        first_name = input('Enter first_name (e.g. John): ')
        last_name = input('Enter last_name (e.g. Doe): ')
        city = input('Enter city of residence (e.g. Pasadena): ')
        state = input('Enter state of residence (e.g. CA): ')
        occupation = input('Enter occupation (e.g. doctor): ')
        add_new_contestant(player_id, first_name, last_name, city, state,
                           occupation)

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
    Everytime a choice of option is selected and produces an output, the 
    options are shown again and the process repeats until the user chooses the
    quit option.
    """
    if (login()):
        while(True):
            show_admin_options()

if __name__ == '__main__':
    # This conn is a global object that other functions can access.
    # You'll need to use cursor = conn.cursor() each time you are
    # about to execute a query with cursor.execute(<sqlquery>)
    conn = get_conn()
    main()
    conn.close()
