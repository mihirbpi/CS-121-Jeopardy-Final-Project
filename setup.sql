-- [Problem 1]
DROP TABLE IF EXISTS games_info;
DROP TABLE IF EXISTS podium_position;
DROP TABLE IF EXISTS contestant;
DROP TABLE IF EXISTS responses;
DROP TABLE IF EXISTS questions;

-- Stores game information, uniquely represented by their game_id.
CREATE TABLE games_info (
    -- game ID, to be exactly 4 characters
    game_id         CHAR(4) NOT NULL,
    -- season of the game, between 16 and 33
    season          INT NOT NULL,
    -- type of season, e.g. Tournament of Champions, optional
    season_type     VARCHAR(500) NOT NULL,
    PRIMARY KEY (game_id)
);

-- Stores podium information for each player in a game.
CREATE TABLE podium_position (
    -- game ID, to be exactly 4 characters
    game_id         CHAR(4) NOT NULL,
    -- player ID, to be exactly 5 characters
    player_id       CHAR(5) NOT NULL,
    -- where player is standing (right, middle, returning champ)
    seat_location   VARCHAR(15),
    PRIMARY KEY (game_id, player_id)
);

-- Stores contestant information, uniquely represented 
-- by their player_id.
CREATE TABLE contestant (
    -- player ID, to be exactly 5 characters
    player_id       CHAR(5) NOT NULL,
    -- first name of the contestant
    first_name      VARCHAR(50) NOT NULL,
    -- last name of the contestant
    last_name       VARCHAR(50) NOT NULL,
    -- hometown city of the contestant
    hometown_city   VARCHAR(100) NOT NULL,
    -- hometown state of the contestant
    hometown_state  VARCHAR(100) NOT NULL,
    -- occupation of the contestant
    occupation      VARCHAR(100) NOT NULL,
    PRIMARY KEY (player_id)
);

-- Stores response information (who answered questions),
-- uniquely represented by the game_id and its location
-- on the game board for each round.
CREATE TABLE responses (
    -- game ID, to be exactly 4 characters
    game_id             CHAR(4) NOT NULL,
    -- round number of the question
    round_num           INT NOT NULL,
    -- row index of question on the board
    row_idx             INT NOT NULL,
    -- column index of question on the board
    column_idx          INT NOT NULL,
    -- position of the contestant who answered the question, 
    correct_respondent  VARCHAR(15) NOT NULL,
    -- value of the question, in dollars
    val                 INT NOT NULL,
    -- amount contestant wagered on the question, if Double Jeopardy
    wager               INT,
    -- position of the contestant who chose the question
    dd_asker  VARCHAR(15) NOT NULL,
    PRIMARY KEY (game_id, round_num, row_idx, column_idx)
);

-- Stores questions, uniquely represented by their game_id
-- and its location on the game board for each round.
CREATE TABLE questions (
    -- game ID, to be exactly 4 characters
    game_id             CHAR(4) NOT NULL,
    -- round number of the question
    round_num           INT NOT NULL,
    -- row index of question on the board
    row_idx             INT NOT NULL,
    -- column index of question on the board
    column_idx          INT NOT NULL,
    -- category of the question
    category    VARCHAR(500)
    -- value of the question, in dollars
    val                 INT NOT NULL,
    -- the question itself
    question    VARCHAR(10000)
    -- the answer to the question
    answer    VARCHAR(10000)
    PRIMARY KEY (game_id, round_num, row_idx, column_idx)
);