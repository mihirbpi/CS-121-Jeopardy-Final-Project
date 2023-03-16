-- Returns table of responses mapped to contestant names and question values.
-- DROP FUNCTION IF EXISTS get_responses;

-- DELIMITER !
-- CREATE FUNCTION get_responses()
-- RETURNS responses_named TABLE (
--     game_id             INT,
--     season              INT,
--     game_year           YEAR,
--     round               VARCHAR(5),
--     row_idx             TINYINT,
--     column_idx          TINYINT,
--     correct_respondent  VARCHAR(100),
--     chooser             VARCHAR(100),
--     wager               VARCHAR(7),
--     question_value      INT NOT NULL
-- )
-- AS
-- BEGIN
-- DECLARE result responses_named;

-- INSERT INTO result
-- SELECT games.game_id, games.season, games.game_year, responses.round, responses.row_idx, responses.column_idx, responses.correct_respondent, responses.chooser, responses.wager, value_mapping.value
-- FROM games
-- NATURAL LEFT JOIN responses
-- NATURAL LEFT JOIN value_mapping;

-- UPDATE result
-- INNER JOIN positions ON result.chooser = positions.seat_location AND result.game_id = positions.game_id
-- INNER JOIN contestants ON positions.player_id = contestants.player_id
-- SET result.chooser = CONCAT(contestants.first_name, ' ', contestants.last_name);

-- UPDATE result
-- INNER JOIN positions ON result.correct_respondent = positions.seat_location AND result.game_id = positions.game_id
-- INNER JOIN contestants ON positions.player_id = contestants.player_id
-- SET result.correct_respondent = CONCAT(contestants.first_name, ' ', contestants.last_name);

-- RETURN result;
-- END !
-- DELIMITER ;

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

-- Procedure to add a new contestant to the database. This procedure is intended 
-- for the admin. 
CREATE PROCEDURE sp_add_contestant(
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
)
proc_label: BEGIN
	IF player_id IN (SELECT player_id FROM contestants) THEN
		LEAVE proc_label;
	ELSE
		INSERT INTO contestants (player_id, first_name, last_name, hometown_city, hometown_state, occupation)
        VALUES (player_id, first_name, last_name, hometown_city, hometown_state, occupation);
    END IF;
    
END !
DELIMITER ;

-- Procedure to add a new game to the database. This procedure is intended for
-- the admin. 
CREATE PROCEDURE sp_add_game(
    -- game ID
    game_id         INT,
    -- season of the game, between 16 and 33
    season          INT,
    -- year that the season correpsonds to
    game_year       YEAR,
    -- player ID
    player_id1      INT,
    -- first name of the contestant
    first_name1     VARCHAR(50) NOT NULL,
    -- last name of the contestant
    last_name1      VARCHAR(50) NOT NULL,
    -- hometown city of the contestant
    hometown_city1  VARCHAR(100),
    -- hometown state of the contestant
    hometown_state1 VARCHAR(100),
    -- occupation of the contestant
    occupation1     VARCHAR(200),
    -- player ID
    player_id2      INT,
    -- first name of the contestant
    first_name2     VARCHAR(50) NOT NULL,
    -- last name of the contestant
    last_name2      VARCHAR(50) NOT NULL,
    -- hometown city of the contestant
    hometown_city2  VARCHAR(100),
    -- hometown state of the contestant
    hometown_state2 VARCHAR(100),
    -- occupation of the contestant
    occupation2     VARCHAR(200),
    -- player ID
    player_id3      INT,
    -- first name of the contestant
    first_name3     VARCHAR(50) NOT NULL,
    -- last name of the contestant
    last_name3      VARCHAR(50) NOT NULL,
    -- hometown city of the contestant
    hometown_city3  VARCHAR(100),
    -- hometown state of the contestant
    hometown_state3 VARCHAR(100),
    -- occupation of the contestant
    occupation3     VARCHAR(200)
)
BEGIN 
    INSERT INTO song_chart_totals 
        -- branch not already in view; add row
        VALUES (new_song_uri, new_chart_date, 1, new_num_streams)
    ON DUPLICATE KEY UPDATE 
        -- branch already in view; update existing row
        num_charts = num_charts + 1,
        total_streams = total_streams + new_num_streams;
END !

-- -- Returns the total earnings of a given player over the course of
-- -- all games they playe between Seasons 16 and 33.
-- DROP FUNCTION IF EXISTS player_winnings;

-- DELIMITER !
-- CREATE FUNCTION player_winnings(player_name VARCHAR(100)) 
-- RETURNS INTEGER DETERMINISTIC
-- BEGIN
--     DECLARE total_pts INTEGER;

--     CREATE TABLE responses_named AS (SELECT *  FROM (games NATURAL LEFT JOIN responses NATURAL LEFT JOIN value_mapping));

--     UPDATE responses_named
--     INNER JOIN positions ON responses_named.chooser = positions.seat_location AND responses_named.game_id = positions.game_id
--     INNER JOIN contestants ON positions.player_id = contestants.player_id
--     SET responses_named.chooser = CONCAT(contestants.first_name, ' ', contestants.last_name);

--     UPDATE responses_named
--     INNER JOIN positions ON responses_named.correct_respondent = positions.seat_location AND responses_named.game_id = positions.game_id
--     INNER JOIN contestants ON positions.player_id = contestants.player_id
--     SET responses_named.correct_respondent = CONCAT(contestants.first_name, ' ', contestants.last_name);

--     SELECT SUM(CASE
--                 WHEN j.correct_respondent = j.chooser AND wager IS NULL THEN j.question_value
--                 WHEN j.correct_respondent = j.chooser AND wager IS NOT NULL THEN j.wager
--                 WHEN j.correct_respondent <> j.chooser AND wager IS NULL THEN -1 * j.question_value
--                 ELSE -1 * j.wager
--             END) AS total_score
--     INTO total_pts
--     FROM responses AS j
--     INNER JOIN contestants AS c ON j.chooser = CONCAT(c.first_name, ' ', c.last_name)
--     INNER JOIN games AS g ON j.game_id = g.game_id
--     WHERE c.player_id IS NOT NULL AND j.chooser = player_name;

--     RETURN total_pts;
-- END !
-- DELIMITER ;