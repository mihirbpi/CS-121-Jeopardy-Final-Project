DROP TABLE IF EXISTS games;
DROP TABLE IF EXISTS positions;
DROP TABLE IF EXISTS contestants;
DROP TABLE IF EXISTS responses;
DROP TABLE IF EXISTS questions;

-- Stores game information, uniquely represented by their game_id.
CREATE TABLE games (
    -- game ID, to be exactly 4 characters
    game_id         CHAR(4) NOT NULL,
    -- season of the game, between 16 and 33
    season          INT NOT NULL,
    PRIMARY KEY (game_id)
);

-- Stores contestant information, uniquely represented 
-- by their player_id.
CREATE TABLE contestants (
    -- player ID, to be exactly 5 characters
    player_id       CHAR(5),
    -- first name of the contestant
    first_name      VARCHAR(50) NOT NULL,
    -- last name of the contestant
    last_name       VARCHAR(50) NOT NULL,
    -- hometown city of the contestant
    hometown_city   VARCHAR(100) NOT NULL,
    -- hometown state of the contestant
    hometown_state  VARCHAR(100) NOT NULL,
    -- occupation of the contestant
    occupation      VARCHAR(200) NOT NULL,
    PRIMARY KEY (player_id)
);

-- Stores podium information for each player in a game.
CREATE TABLE positions (
    -- game ID, to be exactly 4 characters
    game_id         CHAR(4),
    -- player ID, to be exactly 5 characters
    player_id       CHAR(5) NOT NULL,
    -- where player is standing (right, middle, returning champ)
    seat_location   VARCHAR(20),
    PRIMARY KEY (game_id, seat_location)
);

-- Stores response information (who answered questions),
-- uniquely represented by the game_id and its location
-- on the game board for each round.
CREATE TABLE responses (
    -- game ID, to be exactly 4 characters
    game_id             CHAR(4),
    -- round number of the question
    round               CHAR(5),
    -- row index of question on the board
    row_idx             INT NOT NULL,
    -- column index of question on the board
    column_idx          INT NOT NULL,
    -- position of the contestant who answered the question, 
    correct_respondent  VARCHAR(15),
    -- position of the contestant who chose the question
    asker               VARCHAR(15) NOT NULL,
    -- amount contestant wagered on the question, if Double Jeopardy
    wager               VARCHAR(6),
    PRIMARY KEY (game_id, round, row_idx, column_idx)
);

-- Stores questions, uniquely represented by their game_id
-- and its location on the game board for each round.
CREATE TABLE questions (
    -- game ID, to be exactly 4 characters
    game_id             CHAR(4),
    -- round of the question
    round               CHAR(5),
    -- row index of question on the board
    row_idx             INT,
    -- column index of question on the board
    column_idx          INT,
    -- category of the question
    category            VARCHAR(500) NOT NULL,
    -- value of the question, in dollars
    value               INT NOT NULL,
    -- the question itself
    question_text       VARCHAR(1000),
    -- the answer to the question
    answer              VARCHAR(1000),
    PRIMARY KEY (game_id, round, row_idx, column_idx)
);