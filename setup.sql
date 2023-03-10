DROP TABLE IF EXISTS value_mapping;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS responses;
DROP TABLE IF EXISTS positions;
DROP TABLE IF EXISTS contestants;
DROP TABLE IF EXISTS plays;
DROP TABLE IF EXISTS games;

-- Stores game information, uniquely represented by their game_id.
CREATE TABLE games (
    -- game ID
    game_id         INT,
    -- season of the game, between 16 and 33
    season          INT,
    -- year that the season correpsonds to
    game_year       YEAR,
    PRIMARY KEY (game_id)
);

-- Stores contestant information, uniquely represented 
-- by their player_id.
CREATE TABLE contestants (
    -- player ID
    player_id       INT,
    -- first name of the contestant
    first_name      VARCHAR(50) NOT NULL,
    -- last name of the contestant
    last_name       VARCHAR(50) NOT NULL,
    -- hometown city of the contestant
    hometown_city   VARCHAR(100),
    -- hometown state of the contestant
    hometown_state  VARCHAR(100),
    -- occupation of the contestant
    occupation      VARCHAR(200),
    PRIMARY KEY (player_id)
);

-- Stores podium information in each game.
CREATE TABLE plays (
    -- game ID, to be up to 4 characters
    game_id         INT,
    -- where players are standing (right, middle, returning_champ)
    seat_location   VARCHAR(20),
    -- player ID, to be up to 5 characters
    PRIMARY KEY (game_id, seat_location),
    FOREIGN KEY (game_id) REFERENCES games (game_id),
    CHECK (seat_location IN ('right', 'middle', 'returning_champ'))
);

-- Stores podium information for each player in a game.
CREATE TABLE positions (
    -- game ID, to be up to 4 characters
    game_id         INT,
    -- player ID, to be up to 5 characters
    player_id       INT,
    -- where player is standing (right, middle, returning_champ)
    seat_location   VARCHAR(20),
    PRIMARY KEY (game_id, seat_location),
    FOREIGN KEY (game_id) REFERENCES games (game_id),
    CHECK (seat_location IN ('right', 'middle', 'returning_champ'))
);

-- Stores response information (who answered questions),
-- uniquely represented by the game_id and its location
-- on the game board for each round.
CREATE TABLE responses (
    -- game ID, to be up to 4 characters
    game_id             INT,
    -- round number of the question (J, DJ, or final)
    round               VARCHAR(5),
    -- row index of question on the board
    row_idx             TINYINT,
    -- column index of question on the board
    column_idx          TINYINT,
    -- position of the contestant who answered the question, 
    correct_respondent  VARCHAR(100),
    -- position of the contestant who chose the question
    chooser             VARCHAR(100),
    -- amount contestant wagered on the question
    -- did not use numeric since whole number of dollars and issues with 
    -- blanks in data
    wager               VARCHAR(7),
    PRIMARY KEY (game_id, round, row_idx, column_idx),
    FOREIGN KEY (game_id, chooser) 
        REFERENCES positions (game_id, seat_location)
            ON UPDATE CASCADE,
    CHECK (round IN ('J', 'DJ', 'final')),
    CHECK (correct_respondent IN ('right', 'middle', 'returning_champ', NULL))
);

-- Stores questions, uniquely represented by their game_id
-- and its location on the game board for each round.
CREATE TABLE questions (
    -- game ID, to be exactly 4 characters
    game_id             INT,
    -- round of the question
    round               VARCHAR(5),
    -- row index of question on the board
    row_idx             TINYINT,
    -- column index of question on the board
    column_idx          TINYINT,
    -- category of the question
    category            VARCHAR(254),
    -- the question itself
    question_text       TEXT,
    -- the answer to the question
    answer              TEXT,
    PRIMARY KEY (game_id, round, row_idx, column_idx),
    CHECK (round IN ('J', 'DJ', 'final'))
);

-- Stores value of question based on its location on the board and the round.
CREATE TABLE value_mapping (
    -- round of the question
    round               VARCHAR(5),
    -- row index of question on the board
    row_idx             TINYINT,
    -- value of the question, in dollars (100-2000, -1 if final jeopardy)
    -- did not use numeric since whole number of dollars and issues with 
    -- blanks in data
    question_value      VARCHAR(4) NOT NULL,
    PRIMARY KEY (round, row_idx),
    CHECK (round IN ('J', 'DJ', 'final'))
);

CREATE INDEX idx_category ON questions (category);

/*
Index: CREATE INDEX idx_category ON questions (category);

mysql> SELECT SUM(v.question_value) AS total_value 
    ->         FROM questions AS q 
    ->         INNER JOIN value_mapping as v
    ->         ON q.round = v.round AND q.row_idx = v.row_idx
    ->         WHERE q.category BETWEEN 'FOOD' AND 'GRIT';
+-------------+
| total_value |
+-------------+
|     7803000 |
+-------------+
1 row in set (0.16 sec)

mysql> EXPLAIN SELECT SUM(v.question_value) AS total_value 
    ->         FROM questions AS q 
    ->         INNER JOIN value_mapping as v
    ->         ON q.round = v.round AND q.row_idx = v.row_idx
    ->         WHERE q.category BETWEEN 'FOOD' AND 'GRIT';
+----+-------------+-------+------------+--------+---------------+---------+---------+-----------------------------------------+--------+----------+-------------+
| id | select_type | table | partitions | type   | possible_keys | key     | key_len | ref                                     | rows   | filtered | Extra       |
+----+-------------+-------+------------+--------+---------------+---------+---------+-----------------------------------------+--------+----------+-------------+
|  1 | SIMPLE      | q     | NULL       | ALL    | NULL          | NULL    | NULL    | NULL                                    | 254176 |    11.11 | Using where |
|  1 | SIMPLE      | v     | NULL       | eq_ref | PRIMARY       | PRIMARY | 23      | jeopardydb.q.round,jeopardydb.q.row_idx |      1 |   100.00 | NULL        |
+----+-------------+-------+------------+--------+---------------+---------+---------+-----------------------------------------+--------+----------+-------------+
2 rows in set, 1 warning (0.01 sec)

mysql> CREATE INDEX idx_category ON questions (category);
Query OK, 0 rows affected (1.17 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> SELECT SUM(v.question_value) AS total_value 
    ->         FROM questions AS q 
    ->         INNER JOIN value_mapping as v
    ->         ON q.round = v.round AND q.row_idx = v.row_idx
    ->         WHERE q.category BETWEEN 'FOOD' AND 'GRIT';
+-------------+
| total_value |
+-------------+
|     7803000 |
+-------------+
1 row in set (0.04 sec)

mysql> EXPLAIN SELECT SUM(v.question_value) AS total_value 
    ->         FROM questions AS q 
    ->         INNER JOIN value_mapping as v
        ON q.round = v.round AND q.row        INNER JOIN value_mapping as v
    ->         ON q.round = v.round AND q.row_idx = v.row_idx
        WHERE q.category BETWEEN 'FOOD' AND 'GRIT';        ON q.round = v.round AND q.row_idx = v.row_idx
    ->         WHERE q.category BETWEEN 'FOOD' AND 'GRIT';
+----+-------------+-------+------------+--------+---------------+--------------+---------+-----------------------------------------+-------+----------+--------------------------+
| id | select_type | table | partitions | type   | possible_keys | key          | key_len | ref                                     | rows  | filtered | Extra                    |
+----+-------------+-------+------------+--------+---------------+--------------+---------+-----------------------------------------+-------+----------+--------------------------+
|  1 | SIMPLE      | q     | NULL       | range  | idx_category  | idx_category | 1019    | NULL                                    | 16460 |   100.00 | Using where; Using index |
|  1 | SIMPLE      | v     | NULL       | eq_ref | PRIMARY       | PRIMARY      | 23      | jeopardydb.q.round,jeopardydb.q.row_idx |     1 |   100.00 | NULL                     |
+----+-------------+-------+------------+--------+---------------+--------------+---------+-----------------------------------------+-------+----------+--------------------------+
2 rows in set, 1 warning (0.00 sec)

mysql> 

We see that an index on category makes this query about four times as fast
*/