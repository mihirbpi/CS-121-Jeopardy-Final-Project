-- Returns the season of a particular game, given a game_id.
DROP FUNCTION IF EXISTS game_to_season;

DELIMITER !
CREATE FUNCTION game_to_season(game_id INT)
RETURNS INTEGER DETERMINISTIC
BEGIN
DECLARE season INT;

SELECT season 
    FROM games 
    WHERE games.game_id = game_id
INTO season;

RETURN season;
END !
DELIMITER ;

-- Returns the total earnings of a given player over the course of
-- all games they playe between Seasons 16 and 33.
DROP FUNCTION IF EXISTS player_winnings;

DELIMITER !
CREATE FUNCTION player_winnings(player_name VARCHAR(100)) 
RETURNS INTEGER DETERMINISTIC
BEGIN
    DECLARE total_pts INTEGER;

    CREATE TABLE responses_named AS (SELECT *  FROM (games NATURAL LEFT JOIN responses NATURAL LEFT JOIN value_mapping));

    UPDATE responses_named
    INNER JOIN positions ON responses_named.chooser = positions.seat_location AND responses_named.game_id = positions.game_id
    INNER JOIN contestants ON positions.player_id = contestants.player_id
    SET responses_named.chooser = CONCAT(contestants.first_name, ' ', contestants.last_name);

    UPDATE responses_named
    INNER JOIN positions ON responses_named.correct_respondent = positions.seat_location AND responses_named.game_id = positions.game_id
    INNER JOIN contestants ON positions.player_id = contestants.player_id
    SET responses_named.correct_respondent = CONCAT(contestants.first_name, ' ', contestants.last_name);

    SELECT SUM(CASE
                WHEN j.correct_respondent = j.chooser AND wager IS NULL THEN j.question_value
                WHEN j.correct_respondent = j.chooser AND wager IS NOT NULL THEN j.wager
                WHEN j.correct_respondent <> j.chooser AND wager IS NULL THEN -1 * j.question_value
                ELSE -1 * j.wager
            END) AS total_score
    INTO total_pts
    FROM responses_named j
    INNER JOIN contestants c ON j.chooser = CONCAT(c.first_name, ' ', c.last_name)
    INNER JOIN games g ON j.game_id = g.game_id
    WHERE c.player_id IS NOT NULL AND j.chooser = player_name;

    RETURN total_pts;
END !
DELIMITER ;