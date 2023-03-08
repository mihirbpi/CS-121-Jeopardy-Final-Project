DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS responses;
DROP TABLE IF EXISTS positions;
DROP TABLE IF EXISTS contestants;
DROP TABLE IF EXISTS games;

-- Stores game information, uniquely represented by their game_id.
CREATE TABLE games (
    -- game ID
    game_id         INT,
    -- season of the game, between 16 and 33
    season          INT,
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

-- Stores podium information for each player in a game.
CREATE TABLE positions (
    -- game ID, to be up to 4 characters
    game_id         INT,
    -- where player is standing (right, middle, returning_champ)
    player_id       INT,
    seat_location   VARCHAR(20),
    -- player ID, to be up to 5 characters
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
    row_idx             INT,
    -- column index of question on the board
    column_idx          INT,
    -- position of the contestant who answered the question, 
    correct_respondent  VARCHAR(20),
    -- position of the contestant who chose the question
    asker               VARCHAR(20) NOT NULL,
    -- amount contestant wagered on the question, if Daily Double
    wager               VARCHAR(7),
    PRIMARY KEY (game_id, round, row_idx, column_idx),
    FOREIGN KEY (game_id, asker) 
        REFERENCES positions (game_id, seat_location),
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
    row_idx             INT,
    -- column index of question on the board
    column_idx          INT,
    -- category of the question
    category            TEXT,
    -- value of the question, in dollars (100-2000, -1 if final jeopardy)
    question_value      VARCHAR(4) NOT NULL,
    -- the question itself
    question_text       TEXT,
    -- the answer to the question
    answer              TEXT,
    PRIMARY KEY (game_id, round, row_idx, column_idx),
    CHECK (round IN ('J', 'DJ', 'final'))
);