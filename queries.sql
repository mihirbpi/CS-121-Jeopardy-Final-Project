
-- Which players won the most money through Jeopardy?
SELECT CONCAT(c.first_name, ' ', c.last_name) AS contestant,
    SUM(question_points(j.chooser, j.correct_respondent, j.question_value, j.wager)) AS total_score
    FROM (SELECT * FROM games NATURAL LEFT JOIN responses NATURAL LEFT JOIN value_mapping) AS j
    INNER JOIN positions p ON j.correct_respondent = p.seat_location AND j.chooser = p.seat_location AND j.game_id = p.game_id
    INNER JOIN contestants c ON p.player_id = c.player_id
    GROUP BY j.chooser, c.first_name, c.last_name
    ORDER BY total_score DESC
    LIMIT 10;

-- Which players won the most money in season 16?
SELECT CONCAT(c.first_name, ' ', c.last_name) AS contestant,
    SUM(question_points(j.chooser, j.correct_respondent, j.question_value, j.wager)) AS total_score
    FROM (SELECT * FROM games NATURAL LEFT JOIN responses NATURAL LEFT JOIN value_mapping) AS j
    INNER JOIN positions p ON j.correct_respondent = p.seat_location AND j.chooser = p.seat_location AND j.game_id = p.game_id
    INNER JOIN contestants c ON p.player_id = c.player_id
    INNER JOIN games g ON j.game_id = g.game_id
    WHERE g.season = 16
    GROUP BY j.chooser, c.first_name, c.last_name
    ORDER BY total_score DESC
    LIMIT 10;

-- What is the average amount of money won per player?
WITH cp AS (SELECT * FROM positions NATURAL LEFT JOIN contestants),
     num_games AS (SELECT CONCAT(cp.first_name, ' ', cp.last_name) AS contestant,
                          COUNT(DISTINCT game_id) AS num
                   FROM cp
                   GROUP BY cp.first_name, cp.last_name)
SELECT CONCAT(c.first_name, ' ', c.last_name) AS contestant,
    SUM(question_points(j.chooser, j.correct_respondent, j.question_value, j.wager)) / ng.num AS avg_score
    FROM (SELECT * FROM games NATURAL LEFT JOIN responses NATURAL LEFT JOIN value_mapping) j
    INNER JOIN positions p ON j.correct_respondent = p.seat_location AND j.chooser = p.seat_location AND j.game_id = p.game_id
    INNER JOIN contestants c ON p.player_id = c.player_id
    INNER JOIN num_games ng ON CONCAT(c.first_name, ' ', c.last_name) = ng.contestant
    GROUP BY j.chooser, c.first_name, c.last_name, ng.num
    ORDER BY avg_score DESC
    LIMIT 10;

-- What is the average amount of money won per season?
WITH cp AS (SELECT * FROM positions NATURAL LEFT JOIN contestants NATURAL LEFT JOIN games),
     num_games AS (SELECT CONCAT(cp.first_name, ' ', cp.last_name) AS contestant, 
                          cp.season AS season,
                          COUNT(DISTINCT game_id) AS num
                   FROM cp
                   GROUP BY cp.first_name, cp.last_name)
SELECT season, AVG(avg_score * 1.0) as season_avg_score
FROM (
        SELECT CONCAT(c.first_name, ' ', c.last_name) AS contestant, ng.season AS season,
            SUM(question_points(j.chooser, j.correct_respondent, j.question_value, j.wager)) / ng.num AS avg_score
        FROM (SELECT * FROM games NATURAL LEFT JOIN responses NATURAL LEFT JOIN value_mapping) AS j
        INNER JOIN positions p ON j.correct_respondent = p.seat_location AND j.chooser = p.seat_location AND j.game_id = p.game_id
        INNER JOIN contestants AS c ON p.player_id = c.player_id
        INNER JOIN num_games AS ng ON CONCAT(c.first_name, ' ', c.last_name) = ng.contestant
        GROUP BY j.chooser, c.first_name, c.last_name, ng.season
     ) AS t
GROUP BY season
ORDER BY season;

-- -- Which round is most indicative of the final outcome for a given player?
-- SELECT round, AVG(score) as avg_score
--     FROM (SELECT round, SUM(question_value) as score
--         FROM responses NATURAL LEFT JOIN positions
--         NATURAL LEFT JOIN value_mapping NATURAL LEFT JOIN contestants
--         WHERE first_name = "Dru" AND last_name = "Daigle"
--         GROUP BY round
--         ORDER BY round) as scores
--     GROUP BY round
--     ORDER BY round;

-- Add a new contestant to the database.
INSERT INTO contestants (player_id, first_name, last_name, hometown_city, hometown_state, occupation)
    VALUES (11375, "Buford", "Frink", "Pasadena", "CA", "author");