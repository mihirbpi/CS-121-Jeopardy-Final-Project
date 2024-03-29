-- UDFS

-- Returns the points earned for a specific question.
DROP FUNCTION IF EXISTS question_points;

DELIMITER !
CREATE FUNCTION question_points(chooser VARCHAR(100), correct_respondent 
VARCHAR(100), question_value INT, wager VARCHAR(7))
RETURNS INTEGER DETERMINISTIC
BEGIN
-- if the contestant who chose the question is the same as the contestant who
-- asked and question is not a daily double, player wins question value
IF correct_respondent = chooser AND wager = '' THEN
    RETURN question_value;
-- if the contestant who chose the question is the same as the contestant who
-- asked and question is a daily double, player wins wager amount
ELSEIF correct_respondent = chooser THEN
    RETURN wager;
-- if the contestant who chose the question is not the same as the contestant 
-- who asked and question is not a daily double, chooser loses question value
ELSEIF correct_respondent <> chooser AND wager = '' THEN
    RETURN -1 * question_value;
-- if the contestant who chose the question is not the same as the contestant 
-- who asked and question is a daily double, chooser loses wager amount
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
-- See queries.sql for more information on the query itself.
DROP FUNCTION IF EXISTS total_player_winnings;

DELIMITER !
CREATE FUNCTION total_player_winnings(player_name VARCHAR(100)) 
RETURNS INTEGER DETERMINISTIC
BEGIN
    DECLARE total_pts INTEGER;

    WITH cp AS (SELECT * FROM positions NATURAL JOIN contestants),
        num_games AS (SELECT CONCAT(cp.first_name, ' ', cp.last_name) AS 
        contestant,
                            COUNT(DISTINCT game_id) AS num
                    FROM cp
                    GROUP BY cp.first_name, cp.last_name)
    SELECT SUM(question_points(j.chooser, j.correct_respondent, j.
    question_value, j.wager)) AS total_score
        FROM (SELECT * FROM games NATURAL JOIN responses NATURAL JOIN 
        value_mapping) AS j
        INNER JOIN positions p ON j.correct_respondent = p.seat_location 
                   AND j.chooser = p.seat_location AND j.game_id = p.game_id
        INNER JOIN contestants AS c ON p.player_id = c.player_id
        WHERE c.player_id IS NOT NULL AND CONCAT(c.first_name, ' ', c.
        last_name) = player_name
        GROUP BY c.first_name, c.last_name
    INTO total_pts;

    RETURN total_pts;
END !
DELIMITER ;

-- Returns the total earnings of all players within a season, 
-- between 16 and 33.
-- See queries.sql for more information on the query itself.
DROP FUNCTION IF EXISTS total_season_winnings;

DELIMITER !
CREATE FUNCTION total_season_winnings(season INT) 
RETURNS INTEGER DETERMINISTIC
BEGIN
    DECLARE total_pts INTEGER;

    SELECT SUM(question_points(j.chooser, j.correct_respondent, j.
    question_value, j.wager)) AS total_score
        FROM (SELECT * FROM games NATURAL JOIN responses NATURAL JOIN 
        value_mapping) AS j
        INNER JOIN positions AS p ON j.correct_respondent = p.seat_location 
                   AND j.chooser = p.seat_location AND j.game_id = p.game_id
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
-- See queries.sql for more information on the query itself.
DROP FUNCTION IF EXISTS avg_player_winnings;

DELIMITER !
CREATE FUNCTION avg_player_winnings(player_name VARCHAR(100)) 
RETURNS INTEGER DETERMINISTIC
BEGIN
    DECLARE avg_pts INTEGER;

    WITH cp AS (SELECT * FROM positions NATURAL JOIN contestants),
        num_games AS (SELECT CONCAT(cp.first_name, ' ', cp.last_name) AS 
        contestant,
                            COUNT(DISTINCT game_id) AS num
                    FROM cp
                    GROUP BY cp.first_name, cp.last_name)
    SELECT SUM(question_points(j.chooser, j.correct_respondent, j.
    question_value, j.wager)) / ng.num as avg_score
        FROM (SELECT * FROM games NATURAL JOIN responses NATURAL JOIN 
        value_mapping) AS j
        INNER JOIN positions p ON j.correct_respondent = p.seat_location 
                   AND j.chooser = p.seat_location AND j.game_id = p.game_id
        INNER JOIN contestants AS c ON p.player_id = c.player_id
        INNER JOIN num_games AS ng ON CONCAT(c.first_name, ' ', c.last_name) 
        = ng.contestant
        WHERE c.player_id IS NOT NULL AND CONCAT(c.first_name, ' ', c.
        last_name) = player_name
        GROUP BY c.first_name, c.last_name, ng.num
    INTO avg_pts;
    RETURN avg_pts;
END !
DELIMITER ;


-- PROCEDURES

-- Procedure to add a new contestant to the database. This procedure is
-- intended for the admin.
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
        -- insert new player
        INSERT INTO contestants (player_id, first_name, last_name, 
        hometown_city, hometown_state, occupation)
        VALUES (p_player_id, p_first_name, p_last_name, p_hometown_city, 
        p_hometown_state, p_occupation);
END !
DELIMITER ;

-- Procedure to be called by the admin Python app
-- when a user makes a change to the contestants table
-- Inserts username and timestamp of change into the
-- contestant_changes table
DROP PROCEDURE IF EXISTS contestant_change;

DELIMITER !
CREATE PROCEDURE contestant_change(
    -- username
    IN username         VARCHAR(20)
)
sp: BEGIN
    INSERT INTO contestant_changes
    VALUES (username, NOW());
END !
DELIMITER ;


-- TABLES

-- Table for tracking username and timestamp when
-- a user updates the contestant table from
-- the admin Python app
DROP TABLE IF EXISTS contestant_changes;

CREATE TABLE contestant_changes (
    username VARCHAR(20),
    update_time TIMESTAMP,
    PRIMARY KEY (username, update_time)
);

-- Table for tracking how many updates
-- to the contestants table each admin user has made
DROP TABLE IF EXISTS update_stats;

CREATE TABLE update_stats (
    username VARCHAR(20),
    update_amount INT,
    PRIMARY KEY (username)
);


-- TRIGGERS

-- Trigger that increments the number of times
-- an admin user has updated the contestants table in the
-- update_stats table.
-- Is triggered once the admin user updates the
-- contestants table and the info about their update is inserted in the 
-- contestant_changes table.
DELIMITER !
CREATE TRIGGER update_check AFTER INSERT ON contestant_changes
    FOR EACH ROW
    BEGIN 
        IF EXISTS (SELECT username FROM update_stats WHERE username = NEW.
        username) THEN
            UPDATE update_stats SET update_amount = update_amount + 1 WHERE 
            username = NEW.username;
        ELSE
            INSERT INTO update_stats
            VALUES (NEW.username, 1);
        END IF;
    END !
DELIMITER ;