
-- What are the total earnings of the players through Jeopardy?
SELECT CONCAT(c.first_name, ' ', c.last_name) AS contestant,
    -- calculate the total earnings
    SUM(question_points(j.chooser, j.correct_respondent, j.question_value, j.
    wager)) AS total_score
    -- select from a table that maps responses to question values
    FROM (SELECT * FROM games NATURAL JOIN responses NATURAL JOIN 
    value_mapping) AS j
    -- map the positions of the players who responded correctly and chose the 
    -- question to the contestants themselves
    INNER JOIN positions p ON j.correct_respondent = p.seat_location 
               AND j.chooser = p.seat_location AND j.game_id = p.game_id
    INNER JOIN contestants c ON p.player_id = c.player_id
    GROUP BY c.first_name, c.last_name
    -- show the first 10 highest scorers as an example
    ORDER BY total_score DESC
    LIMIT 10;

-- What are the total earnings of the players in season 16?
SELECT CONCAT(c.first_name, ' ', c.last_name) AS contestant,
    SUM(question_points(j.chooser, j.correct_respondent, j.question_value, j.
    wager)) AS total_score
    FROM (SELECT * FROM games NATURAL JOIN responses NATURAL JOIN 
    value_mapping) AS j
    INNER JOIN positions AS p ON j.correct_respondent = p.seat_location 
               AND j.chooser = p.seat_location AND j.game_id = p.game_id
    INNER JOIN contestants AS c ON p.player_id = c.player_id
    INNER JOIN games AS g ON j.game_id = g.game_id
    -- specify  which season to calculate total player earnings from
    WHERE g.season = 16
    GROUP BY c.first_name, c.last_name
    -- show the first 10 highest scorers as an example
    ORDER BY total_score DESC
    LIMIT 10;

-- What is the average amount of money won per player?
-- map conestants to their seat locations in each game they play
WITH cp AS (SELECT * FROM positions NATURAL JOIN contestants),
    -- map each player to the number of games that they play
    num_games AS (SELECT CONCAT(cp.first_name, ' ', cp.last_name) AS 
    contestant,
                          COUNT(DISTINCT game_id) AS num
                  FROM cp
                  GROUP BY cp.first_name, cp.last_name)
SELECT CONCAT(c.first_name, ' ', c.last_name) AS contestant,
    -- calculate the average earnings
    SUM(question_points(j.chooser, j.correct_respondent, j.question_value, j.
    wager)) / ng.num AS avg_score
    FROM (SELECT * FROM games NATURAL JOIN responses NATURAL JOIN 
    value_mapping) AS j
    INNER JOIN positions AS p ON j.correct_respondent = p.seat_location 
               AND j.chooser = p.seat_location AND j.game_id = p.game_id
    INNER JOIN contestants AS c ON p.player_id = c.player_id
    -- map number of games played to the player
    INNER JOIN num_games AS ng ON CONCAT(c.first_name, ' ', c.last_name) = ng.
    contestant
    GROUP BY c.first_name, c.last_name, ng.num
    -- show the first 10 highest average scorers as an example
    ORDER BY avg_score DESC
    LIMIT 10;

-- What is the average amount of money won per season?
WITH cp AS (SELECT * FROM positions NATURAL JOIN contestants NATURAL JOIN 
games),
    -- map each player to the number of games that they play per season
    num_games AS (SELECT CONCAT(cp.first_name, ' ', cp.last_name) AS 
    contestant, 
                         cp.season AS season,
                         COUNT(DISTINCT game_id) AS num
                    FROM cp
                    GROUP BY cp.first_name, cp.last_name, cp.season)
-- average earnings over all seasons
SELECT season, AVG(avg_score * 1.0) as season_avg_score
    -- select from a table of average earnings per player, per season
    FROM (SELECT CONCAT(c.first_name, ' ', c.last_name) AS contestant, ng.
    season AS season,
                SUM(question_points(j.chooser, j.correct_respondent, j.
                question_value, j.wager)) / ng.num AS avg_score
            FROM (SELECT * FROM games NATURAL JOIN responses NATURAL JOIN 
            value_mapping) AS j
            INNER JOIN positions p ON j.correct_respondent = p.seat_location 
            AND j.chooser = p.seat_location AND j.game_id = p.game_id
            INNER JOIN contestants AS c ON p.player_id = c.player_id
            INNER JOIN num_games AS ng ON CONCAT(c.first_name, ' ', c.
            last_name) = ng.contestant
            GROUP BY c.first_name, c.last_name, ng.season, ng.num
        ) AS t
    GROUP BY season
    ORDER BY season;

-- Add a new contestant to the database.
INSERT INTO contestants (player_id, first_name, last_name, hometown_city, 
hometown_state, occupation)
    VALUES (11375, 'Buford', 'Frink', 'Pasadena', 'CA', 'author');