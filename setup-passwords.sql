-- File for Password Management section of Final Project

-- (Provided) This function generates a specified number of characters for using as a
-- salt in passwords.
DELIMITER !
CREATE FUNCTION make_salt(num_chars INT) 
RETURNS VARCHAR(20) NOT DETERMINISTIC
BEGIN
    DECLARE salt VARCHAR(20) DEFAULT '';

    -- Don't want to generate more than 20 characters of salt.
    SET num_chars = LEAST(20, num_chars);

    -- Generate the salt!  Characters used are ASCII code 32 (space)
    -- through 126 ('z').
    WHILE num_chars > 0 DO
        SET salt = CONCAT(salt, CHAR(32 + FLOOR(RAND() * 95)));
        SET num_chars = num_chars - 1;
    END WHILE;

    RETURN salt;
END !
DELIMITER ;

-- Provided (you may modify if you choose)
-- This table holds information for authenticating users based on
-- a password.  Passwords are not stored plaintext so that they
-- cannot be used by people that shouldn't have them.
-- You may extend that table to include an is_admin or role attribute if you 
-- have admin or other roles for users in your application 
-- (e.g. store managers, data managers, etc.)
CREATE TABLE user_info (
    -- Usernames are up to 20 characters.
    username VARCHAR(20) PRIMARY KEY,

    -- Salt will be 8 characters all the time, so we can make this 8.
    salt CHAR(8) NOT NULL,

    -- We use SHA-2 with 256-bit hashes.  MySQL returns the hash
    -- value as a hexadecimal string, which means that each byte is
    -- represented as 2 characters.  Thus, 256 / 8 * 2 = 64.
    -- We can use BINARY or CHAR here; BINARY simply has a different
    -- definition for comparison/sorting than CHAR.
    password_hash BINARY(64) NOT NULL
);

-- [Problem 1a]
-- Adds a new user to the user_info table, using the specified password (max
-- of 20 characters). Salts the password with a newly-generated salt value,
-- and then the salt and hash values are both stored in the table.
DELIMITER !
CREATE PROCEDURE sp_add_user(new_username VARCHAR(20), password VARCHAR(20), is_admin TINYINT(1))
BEGIN
  DECLARE salt CHAR(8);
  DECLARE temp_pass VARCHAR(28);
  DECLARE hash_pass BINARY(64);

  SET salt = make_salt(8);
  SET temp_pass = CONCAT(salt, password);
  set hash_pass = SHA2(temp_pass, 256);

  INSERT INTO user_info VALUES (new_username, salt, hash_pass), is_admin;
END !
DELIMITER ;

-- [Problem 1b]
-- Authenticates the specified username and password against the data
-- in the user_info table.  Returns 1 if the user appears in the table, and the
-- specified password hashes to the value for the user. Otherwise returns 0.
DELIMITER !
CREATE FUNCTION authenticate(username VARCHAR(20), password VARCHAR(20))
RETURNS TINYINT DETERMINISTIC
BEGIN
  DECLARE salt CHAR(8);
  DECLARE temp_pass VARCHAR(28);
  DECLARE hash_pass BINARY(64);

  -- check if the username is in the database
  IF username NOT IN (SELECT user FROM user_info) 
    THEN RETURN 0;
  END IF;

  -- check if the salted password is the same as what's in the database
  SELECT salt, password_hash INTO salt, hash_pass 
    FROM user_info 
    WHERE username = user LIMIT 1;
  
  SET temp = CONCAT(salt, password);
  IF SHA2(temp, 256) = hash_pass
    THEN RETURN 1;
  ELSE RETURN 0;
  END IF;
END !
DELIMITER ;

-- [Problem 1c]
-- Add at least two users into your user_info table so that when we run this file,
-- we will have examples users in the database.
CALL sp_add_user('mborkar', 'il0veCS');
CALL sp_add_user('rkurinch', 'f0rg0tPa$$w0rd')

-- [Problem 1d]
-- Optional: Create a procedure sp_change_password to generate a new salt and change the given
-- user's password to the given password (after salting and hashing)
DELIMITER !
CREATE PROCEDURE sp_change_password(user VARCHAR(20), password VARCHAR(20))
BEGIN
  DECLARE salt CHAR(8);
  DECLARE temp_pass VARCHAR(28);
  DECLARE hash_pass BINARY(64);

  SET salt = make_salt(8);
  SET temp_pass = CONCAT(salt, password);
  set hash_pass = SHA2(temp_pass, 256);

  UPDATE user_info 
    SET salt = salt, password_hash = hash_pass
    WHERE username = user;
END !
DELIMITER ;
