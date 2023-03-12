-- Which player won the most money through Jeopardy?
SELECT first_name, last_name, total_score
    FROM (SELECT first_name, last_name, SUM(question_value) as total_score
        FROM games NATURAL LEFT JOIN positions NATURAL LEFT JOIN contestants
            NATURAL LEFT JOIN value_mapping NATURAL LEFT JOIN responses
        GROUP BY first_name, last_name
        ORDER BY total_score DESC) as scores
    GROUP BY first_name, last_name
    ORDER BY total_score DESC
    LIMIT 1;

-- Which player won the most money in season 16?
SELECT first_name, last_name, total_score
    FROM (SELECT first_name, last_name, season, SUM(question_value) as total_score
        FROM games NATURAL LEFT JOIN positions NATURAL LEFT JOIN contestants
            NATURAL LEFT JOIN value_mapping NATURAL LEFT JOIN responses
        WHERE season = 16
        GROUP BY first_name, last_name
        ORDER BY total_score DESC) as scores
    GROUP BY first_name, last_name
    ORDER BY total_score DESC;

-- What is the average amount of money won per player?
SELECT first_name, last_name, avg(score) as avg_score
    FROM (SELECT first_name, last_name, SUM(question_value) as score
        FROM games NATURAL LEFT JOIN positions NATURAL LEFT JOIN contestants
            NATURAL LEFT JOIN value_mapping NATURAL LEFT JOIN responses
        GROUP BY first_name, last_name
        ORDER BY score DESC) as scores
    GROUP BY first_name, last_name
    ORDER BY avg_score DESC;

-- What is the average amount of money won per season?
SELECT season, AVG(score) as avg_score
    FROM (SELECT first_name, last_name, season, SUM(question_value) as score
        FROM games NATURAL LEFT JOIN positions NATURAL LEFT JOIN contestants
            NATURAL LEFT JOIN value_mapping NATURAL LEFT JOIN responses
        GROUP BY first_name, last_name, season
        ORDER BY score DESC) as scores
    GROUP BY season
    ORDER BY season; 

-- Add a new contestant to the database.
INSERT INTO contestants (player_id, first_name, last_name, hometown_city, hometown_state, occupation)
    VALUES (11375, "Buford", "Frink", "Pasadena", "CA", "author");