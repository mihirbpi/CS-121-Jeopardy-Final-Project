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
-- all games they playe between Seasons 16 and 33.
DROP FUNCTION IF EXISTS player_winnings;

DELIMITER !
CREATE FUNCTION player_winnings(player_name VARCHAR(100)) 
RETURNS INTEGER DETERMINISTIC
BEGIN
    DECLARE total_pts INTEGER;
    
    SELECT SUM(CASE
                WHEN j.correct_respondent = j.chooser AND wager IS NULL THEN j.question_value
                WHEN j.correct_respondent = j.chooser AND wager IS NOT NULL THEN j.wager
                WHEN j.correct_respondent <> j.chooser AND wager IS NULL THEN -1 * j.question_value
                ELSE -1 * j.wager
            END) AS total_score
    INTO total_pts
    FROM responses AS j
    INNER JOIN contestants AS c ON j.chooser = CONCAT(c.first_name, ' ', c.last_name)
    INNER JOIN games AS g ON j.game_id = g.game_id
    WHERE c.player_id IS NOT NULL AND j.chooser = player_name;

    RETURN total_pts;
END !
DELIMITER ;