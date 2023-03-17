-- UDFS

-- Returns the points earned for a specific question.
DROP FUNCTION IF EXISTS question_points;

DELIMITER !
CREATE FUNCTION question_points(chooser VARCHAR(100), correct_respondent VARCHAR(100), question_value INT, wager VARCHAR(7))
RETURNS INTEGER DETERMINISTIC
BEGIN
IF correct_respondent = chooser AND wager = '' THEN
    RETURN question_value;
ELSEIF correct_respondent = chooser THEN
    RETURN wager;
ELSEIF correct_respondent <> chooser AND wager = '' THEN
    RETURN -1 * question_value;
ELSE
    RETURN -1 * wager;
END IF;
END !
DELIMITER ;

-- Returns the season of a particular game, given a game_id.
DROP FUNCTION IF EXISTS game_to_season;

DELIMITER !
CREATE FUNCTION game_to_season(game_id INT)
RETURNS INTEGER DETERMINISTIC
BEGIN
DECLARE local_season INT;

SELECT season
    FROM games 
    WHERE games.game_id = game_id
INTO local_season;

RETURN local_season;
END !
DELIMITER ;

-- Returns the total earnings of a given player over the course of
-- all games they played between Seasons 16 and 33.
DROP FUNCTION IF EXISTS total_player_winnings;

DELIMITER !
CREATE FUNCTION total_player_winnings(player_name VARCHAR(100)) 
RETURNS INTEGER DETERMINISTIC
BEGIN
    DECLARE total_pts INTEGER;

    WITH cp AS (SELECT * FROM positions NATURAL LEFT JOIN contestants),
        num_games AS (SELECT CONCAT(cp.first_name, ' ', cp.last_name) AS contestant,
                            COUNT(DISTINCT game_id) AS num
                    FROM cp
                    GROUP BY cp.first_name, cp.last_name)
    SELECT SUM(question_points(j.chooser, j.correct_respondent, j.question_value, j.wager)) AS total_score
        FROM (SELECT * FROM games NATURAL LEFT JOIN responses NATURAL LEFT JOIN value_mapping) AS j
        INNER JOIN positions p ON j.correct_respondent = p.seat_location AND j.chooser = p.seat_location AND j.game_id = p.game_id
        INNER JOIN contestants AS c ON p.player_id = c.player_id
        WHERE c.player_id IS NOT NULL AND CONCAT(c.first_name, ' ', c.last_name) = player_name
        GROUP BY c.first_name, c.last_name
    INTO total_pts;

    RETURN total_pts;
END !
DELIMITER ;

-- Returns the total earnings of all players within a season, between 16 and 33.
DROP FUNCTION IF EXISTS total_season_winnings;

DELIMITER !
CREATE FUNCTION total_season_winnings(season INT) 
RETURNS INTEGER DETERMINISTIC
BEGIN
    DECLARE total_pts INTEGER;

    SELECT SUM(question_points(j.chooser, j.correct_respondent, j.question_value, j.wager)) AS total_score
        FROM (SELECT * FROM games NATURAL LEFT JOIN responses NATURAL LEFT JOIN value_mapping) AS j
        INNER JOIN positions AS p ON j.correct_respondent = p.seat_location AND j.chooser = p.seat_location AND j.game_id = p.game_id
        INNER JOIN contestants AS c ON p.player_id = c.player_id
        INNER JOIN games AS g ON j.game_id = g.game_id
        WHERE g.season = season
        GROUP BY g.season
    INTO total_pts;
    RETURN total_pts;
END !
DELIMITER ;

-- Returns the total earnings of a given player over the course of
-- all games they played between Seasons 16 and 33.
DROP FUNCTION IF EXISTS avg_player_winnings;

DELIMITER !
CREATE FUNCTION avg_player_winnings(player_name VARCHAR(100)) 
RETURNS INTEGER DETERMINISTIC
BEGIN
    DECLARE avg_pts INTEGER;

    WITH cp AS (SELECT * FROM positions NATURAL LEFT JOIN contestants),
        num_games AS (SELECT CONCAT(cp.first_name, ' ', cp.last_name) AS contestant,
                            COUNT(DISTINCT game_id) AS num
                    FROM cp
                    GROUP BY cp.first_name, cp.last_name)
    SELECT SUM(question_points(j.chooser, j.correct_respondent, j.question_value, j.wager)) / ng.num as avg_score
        FROM (SELECT * FROM games NATURAL LEFT JOIN responses NATURAL LEFT JOIN value_mapping) AS j
        INNER JOIN positions p ON j.correct_respondent = p.seat_location AND j.chooser = p.seat_location AND j.game_id = p.game_id
        INNER JOIN contestants AS c ON p.player_id = c.player_id
        INNER JOIN num_games AS ng ON CONCAT(c.first_name, ' ', c.last_name) = ng.contestant
        WHERE c.player_id IS NOT NULL AND CONCAT(c.first_name, ' ', c.last_name) = player_name
        GROUP BY c.first_name, c.last_name, ng.num
    INTO avg_pts;
    RETURN avg_pts;
END !
DELIMITER ;


-- PROCEDURES

-- Procedure to add a new contestant to the database. This procedure is intended 
-- for the admin.
DROP PROCEDURE IF EXISTS sp_add_contestant;

DELIMITER !
CREATE PROCEDURE sp_add_contestant(
    -- player ID
    IN p_player_id          INT,
    -- first name of the contestant
    IN p_first_name         VARCHAR(50),
    -- last name of the contestant
    IN p_last_name          VARCHAR(50),
    -- hometown city of the contestant
    IN p_hometown_city      VARCHAR(100),
    -- hometown state of the contestant
    IN p_hometown_state     VARCHAR(100),
    -- occupation of the contestant
    IN p_occupation         VARCHAR(200)
)
sp: BEGIN
    IF EXISTS (SELECT player_id FROM contestants WHERE player_id = p_player_id) THEN
        -- player already exists, exit procedure
        LEAVE sp;
    ELSE
        -- insert new player
        INSERT INTO contestants (player_id, first_name, last_name, hometown_city, hometown_state, occupation)
        VALUES (p_player_id, p_first_name, p_last_name, p_hometown_city, p_hometown_state, p_occupation);
    END IF;
END !
DELIMITER ;

-- Procedure to add a new game to the database. This procedure is intended for
-- the admin. 
DROP PROCEDURE IF EXISTS sp_add_game;

DELIMITER !
CREATE PROCEDURE sp_add_game(
    -- game ID
    IN g_game_id         INT,
    -- season of the game, between 16 and 33
    IN g_season          INT,
    -- year that the season correpsonds to
    IN g_game_year       YEAR,
    -- player 1 ID
    IN g_player_id1      INT,
    -- first name of contestant 1
    IN g_first_name1     VARCHAR(50),
    -- last name of contestant 1
    IN g_last_name1      VARCHAR(50),
    -- hometown city of contestant 1
    IN g_hometown_city1  VARCHAR(100),
    -- hometown state of contestant 1
    IN g_hometown_state1 VARCHAR(100),
    -- occupation of contestant 1
    IN g_occupation1     VARCHAR(200),
    -- player 2 ID
    IN g_player_id2      INT,
    -- first name of contestant 2
    IN g_first_name2     VARCHAR(50),
    -- last name of contestant 2
    IN g_last_name2      VARCHAR(50),
    -- hometown city of contestant 2
    IN g_hometown_city2  VARCHAR(100),
    -- hometown state of contestant 2
    IN g_hometown_state2 VARCHAR(100),
    -- occupation of contestant 2
    IN g_occupation2     VARCHAR(200),
    -- player 3 ID
    IN g_player_id3      INT,
    -- first name of contestant 3
    IN g_first_name3     VARCHAR(50),
    -- last name of contestant 3
    IN g_last_name3      VARCHAR(50),
    -- hometown city of contestant 3
    IN g_hometown_city3  VARCHAR(100),
    -- hometown state of contestant 3
    IN g_hometown_state3 VARCHAR(100),
    -- occupation of contestant 3
    IN g_occupation3     VARCHAR(200)
)
sp: BEGIN
	IF EXISTS (SELECT game_id FROM games WHERE game_id = g_game_id) THEN
		LEAVE sp;
	ELSE
		INSERT INTO games (game_id, season, game_year)
        VALUES (g_game_id, g_season, g_game_year);
        CALL sp_add_contestant(g_player_id1, g_first_name1, g_last_name1, g_hometown_city1, g_hometown_state1, g_occupation1);
        CALL sp_add_contestant(g_player_id2, g_first_name2, g_last_name2, g_hometown_city2, g_hometown_state2, g_occupation2);
        CALL sp_add_contestant(g_player_id3, g_first_name3, g_last_name3, g_hometown_city3, g_hometown_state3, g_occupation3);
    END IF;
END !
DELIMITER ;

-- Procedure to add a new contestant position to the database. This procedure is 
-- intended for the admin.
DROP PROCEDURE IF EXISTS sp_add_position;

DELIMITER !
CREATE PROCEDURE sp_add_position(
    -- game ID
    IN g_game_id         INT,
    -- player ID
    IN g_player_id       INT,
    -- where player is standing (right, middle, returning_champ)
    IN g_seat_location   VARCHAR(20)
)
sp: BEGIN
    IF EXISTS (SELECT g_game_id, g_player_id FROM positions WHERE game_id = g_game_id AND player_id = g_player_id) THEN
        LEAVE sp;
    ELSE
        INSERT INTO positions (game_id, player_id, seat_location)
        VALUES (g_game_id, g_player_id, g_seat_location);
    END IF;
END !
DELIMITER ;

-- Procedure to add a new question response to the database. This procedure is 
-- intended for the admin.
DROP PROCEDURE IF EXISTS sp_add_response;

DELIMITER !
CREATE PROCEDURE sp_add_response(
    -- game ID, to be up to 4 characters
    IN r_game_id             INT,
    -- round number of the question (J, DJ, or final)
    IN r_round               VARCHAR(5),
    -- row index of question on the board
    IN r_row_idx             TINYINT,
    -- column index of question on the board
    IN r_column_idx          TINYINT,
    -- position of the contestant who answered the question, 
    IN r_correct_respondent  VARCHAR(100),
    -- position of the contestant who chose the question
    IN r_chooser             VARCHAR(100),
    -- amount contestant wagered on the question
    IN r_wager               VARCHAR(7)
)
sp: BEGIN
    IF EXISTS (SELECT r_game_id, r_round, r_row_idx, r_column_idx FROM responses 
        WHERE game_id = r_game_id AND round = r_round AND row_idx = r_row_idx AND
        column_idx = r_column_idx) THEN
        LEAVE sp;
    ELSE
        INSERT INTO responses (game_id, round, row_idx, column_idx, correct_respondent, chooser, wager)
        VALUES (r_game_id, r_round, r_row_idx, r_column_idx, r_correct_respondent, r_chooser, r_wager);
    END IF;
END !
DELIMITER ;

-- Procedure to add a new question to the database. This procedure is 
-- intended for the admin.
DROP PROCEDURE IF EXISTS sp_add_question;

DELIMITER !
CREATE PROCEDURE sp_add_question(
    -- game ID, to be exactly 4 characters
    IN q_game_id             INT,
    -- round of the question
    IN q_round               VARCHAR(5),
    -- row index of question on the board
    IN q_row_idx             TINYINT,
    -- column index of question on the board
    IN q_column_idx          TINYINT,
    -- category of the question
    IN q_category            VARCHAR(254),
    -- the question itself
    IN q_question_text       TEXT,
    -- the answer to the question
    IN q_answer              TEXT
)
sp: BEGIN
    IF EXISTS (SELECT q_game_id, q_round, q_row_idx, q_column_idx FROM questions 
        WHERE game_id = q_game_id AND round = q_round AND row_idx = q_row_idx AND
        column_idx = q_column_idx) THEN
        LEAVE sp;
    ELSE
        INSERT INTO questions (game_id, round, row_idx, column_idx, category, question_text, answer)
        VALUES (q_game_id, q_round, q_row_idx, q_column_idx, q_category, q_question_text, q_answer);
    END IF;
END !
DELIMITER ;

-- TRIGGER
