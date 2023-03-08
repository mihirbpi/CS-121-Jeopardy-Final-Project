-- Instructions:
-- This script will load the CSV files into the tables you created in setup.sql.
-- Intended for use with the command-line MySQL, otherwise unnecessary for
-- phpMyAdmin (just import each CSV file in the GUI).

-- Make sure this file is in the same directory as your CSV files and
-- setup.sql. Then run the following in the mysql> prompt (assuming
-- you have a spotifydb created with CREATE DATABASE spotifydb;):
-- USE DATABASE jeopardydb; 
-- source setup.sql; (make sure no warnings appear)
-- source load-data.sql; (make sure there are 0 skipped/warnings)
SET GLOBAL local_infile=1;

-- [Problem 1]
LOAD DATA LOCAL INFILE 'data/games.csv' INTO TABLE games
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

-- [Problem 2]
LOAD DATA LOCAL INFILE 'data/contestants.csv' INTO TABLE contestants
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

-- -- [Problem 3]
LOAD DATA LOCAL INFILE 'data/positions.csv' INTO TABLE positions
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

-- -- [Problem 4]
LOAD DATA LOCAL INFILE 'data/responses.csv' INTO TABLE responses
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'data/questions.csv' INTO TABLE questions
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY """" ESCAPED BY "\\" LINES TERMINATED BY '\n' IGNORE 1 ROWS;