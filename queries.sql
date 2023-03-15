CREATE TABLE responses_named AS (SELECT *  FROM (games NATURAL LEFT JOIN responses NATURAL LEFT JOIN value_mapping));

UPDATE responses_named
INNER JOIN positions ON responses_named.chooser = positions.seat_location AND responses_named.game_id = positions.game_id
INNER JOIN contestants ON positions.player_id = contestants.player_id
SET responses_named.chooser = CONCAT(contestants.first_name, ' ', contestants.last_name);

UPDATE responses_named
INNER JOIN positions ON responses_named.correct_respondent = positions.seat_location AND responses_named.game_id = positions.game_id
INNER JOIN contestants ON positions.player_id = contestants.player_id
SET responses_named.correct_respondent = CONCAT(contestants.first_name, ' ', contestants.last_name);

-- Which player won the most money through Jeopardy?
SELECT CONCAT(c.first_name, ' ', c.last_name) AS contestant,
       SUM(CASE
             WHEN j.correct_respondent = j.chooser AND wager IS NULL THEN j.question_value
             WHEN j.correct_respondent = j.chooser and wager IS NOT NULL then j.wager
             WHEN j.correct_respondent <> j.chooser AND wager IS NULL THEN -1 * j.question_value
             ELSE -1 * j.wager
           END) AS total_score
FROM responses_named j
INNER JOIN contestants c
ON j.chooser = CONCAT(c.first_name, ' ', c.last_name)
GROUP BY j.chooser, c.first_name, c.last_name
ORDER BY total_score DESC
LIMIT 1;

-- Which player won the most money in season 16?
SELECT CONCAT(c.first_name, ' ', c.last_name) AS contestant,
       SUM(CASE
             WHEN j.correct_respondent = j.chooser AND wager IS NULL THEN j.question_value
             WHEN j.correct_respondent = j.chooser and wager IS NOT NULL then j.wager
             WHEN j.correct_respondent <> j.chooser AND wager IS NULL THEN -1 * j.question_value
             ELSE -1 * j.wager
           END) AS total_score
FROM responses_named j
INNER JOIN contestants c ON j.chooser = CONCAT(c.first_name, ' ', c.last_name)
INNER JOIN games g ON j.game_id = g.game_id
WHERE g.season = 16
GROUP BY j.chooser, c.first_name, c.last_name
ORDER BY total_score DESC
LIMIT 1;

-- What is the average amount of money won per player?
WITH cp AS (SELECT * FROM positions NATURAL LEFT JOIN contestants),
     num_games AS (SELECT CONCAT(cp.first_name, ' ', cp.last_name) AS contestant,
                          COUNT(DISTINCT game_id) AS num
                   FROM cp
                   GROUP BY cp.first_name, cp.last_name)
SELECT CONCAT(c.first_name, ' ', c.last_name) AS contestant,
       SUM(CASE
               WHEN j.correct_respondent = j.chooser AND wager IS NULL THEN j.question_value
               WHEN j.correct_respondent = j.chooser AND wager IS NOT NULL THEN j.wager
               WHEN j.correct_respondent <> j.chooser AND wager IS NULL THEN -1 * j.question_value
               ELSE -1 * j.wager
           END) / ng.num AS avg_score
FROM responses_named j
INNER JOIN contestants c ON j.chooser = CONCAT(c.first_name, ' ', c.last_name)
INNER JOIN num_games ng ON j.chooser = ng.contestant
LEFT JOIN cp ON c.player_id = cp.player_id
GROUP BY j.chooser, c.first_name, c.last_name, ng.num;


-- What is the average amount of money won per season?
WITH cp AS (SELECT * FROM positions NATURAL LEFT JOIN contestants NATURAL LEFT JOIN games),
     num_games AS (SELECT CONCAT(cp.first_name, ' ', cp.last_name) AS contestant, 
                          cp.season AS season,
                          COUNT(DISTINCT game_id) AS num
                   FROM cp
                   GROUP BY cp.first_name, cp.last_name)
SELECT season, AVG(avg_score) as season_avg_score
    FROM SELECT CONCAT(c.first_name, ' ', c.last_name) AS contestant, ng.season as season,
        SUM(CASE
                WHEN j.correct_respondent = j.chooser AND wager IS NULL THEN j.question_value
                WHEN j.correct_respondent = j.chooser AND wager IS NOT NULL THEN j.wager
                WHEN j.correct_respondent <> j.chooser AND wager IS NULL THEN -1 * j.question_value
                ELSE -1 * j.wager
            END) / ng.num AS avg_score
    FROM responses_named j
    INNER JOIN contestants c ON j.chooser = CONCAT(c.first_name, ' ', c.last_name)
    INNER JOIN num_games ng ON j.chooser = ng.contestant
    LEFT JOIN cp ON c.player_id = cp.player_id
    GROUP BY j.chooser, c.first_name, c.last_name, ng.num
GROUP BY season
ORDER BY season;

-- Which round is most indicative of the final outcome for a given player?
SELECT round, AVG(score) as avg_score
    FROM (SELECT round, SUM(question_value) as score
        FROM responses NATURAL LEFT JOIN positions
        NATURAL LEFT JOIN value_mapping NATURAL LEFT JOIN contestants
        WHERE first_name = "Dru" AND last_name = "Daigle"
        GROUP BY round
        ORDER BY round) as scores
    GROUP BY round
    ORDER BY round;

-- WITH cp AS (SELECT * FROM positions NATURAL LEFT JOIN contestants),
--      num_games AS (SELECT CONCAT(cp.first_name, ' ', cp.last_name) AS contestant,
--                           COUNT(DISTINCT game_id) AS num
--                    FROM cp
--                    GROUP BY cp.first_name, cp.last_name)
-- SELECT CONCAT(c.first_name, ' ', c.last_name) AS contestant,
--        j.round as round,
--        SUM(CASE
--                WHEN j.correct_respondent = j.chooser AND wager IS NULL THEN j.question_value AND j.round = round
--                WHEN j.correct_respondent = j.chooser AND wager IS NOT NULL THEN j.wager AND j.round = round
--                WHEN j.correct_respondent <> j.chooser AND wager IS NULL THEN -1 * j.question_value AND j.round = round
--                ELSE -1 * j.wager
--            END) / ng.num AS avg_score
-- FROM responses_named j
-- INNER JOIN contestants c ON j.chooser = CONCAT(c.first_name, ' ', c.last_name)
-- INNER JOIN num_games ng ON j.chooser = ng.contestant
-- LEFT JOIN cp ON c.player_id = cp.player_id
-- WHERE ng.contestant = "Dru Daigle"
-- GROUP BY j.chooser, c.first_name, c.last_name, ng.num;

-- WITH winners as (
--     SELECT s1.*
--     FROM (SELECT game_id, player_id, SUM(question_value) as total_score
--         FROM positions NATURAL LEFT JOIN value_mapping NATURAL LEFT JOIN questions NATURAL LEFT JOIN responses
--         GROUP BY game_id, player_id
--         ORDER BY game_id) s1 
--     LEFT JOIN (SELECT game_id, player_id, SUM(question_value) as total_score
--         FROM positions NATURAL LEFT JOIN value_mapping NATURAL LEFT JOIN responses
--         GROUP BY game_id, player_id
--         ORDER BY game_id) s2s
--         ON s1.game_id = s2.game_id 
--         AND s1.total_score < s2.total_score 
--     WHERE s2.total_score IS NULL 
-- )
-- SELECT round, AVG(total_score)
--     FROM (SELECT game_id, player_id, round, SUM(question_value) as total_score
--         FROM positions NATURAL LEFT JOIN value_mapping NATURAL LEFT JOIN questions NATURAL LEFT JOIN responses
--         GROUP BY game_id, player_id
--         ORDER BY game_id
--         WHERE game_id = winners.game_id AND player_id = winners.player_id) as scores
--     GROUP BY round;


-- Add a new contestant to the database.
INSERT INTO contestants (player_id, first_name, last_name, hometown_city, hometown_state, occupation)
    VALUES (11375, "Buford", "Frink", "Pasadena", "CA", "author");