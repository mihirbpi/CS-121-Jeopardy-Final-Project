DROP USER IF EXISTS 'jeopardyadmin'@'localhost';
DROP USER IF EXISTS 'jeopardyclient'@'localhost';

CREATE USER 'jeopardyadmin'@'localhost' IDENTIFIED BY 'adminpw';
CREATE USER 'jeopardyclient'@'localhost' IDENTIFIED BY 'clientpw';

-- Can add more users or refine permissions
GRANT ALL PRIVILEGES ON jeopardydb.* TO 'jeopardyadmin'@'localhost';
GRANT SELECT ON jeopardydb.* TO 'jeopardyclient'@'localhost';
GRANT EXECUTE ON FUNCTION jeopardydb.authenticate TO 'jeopardyclient'@'localhost';
GRANT EXECUTE ON FUNCTION jeopardydb.avg_player_winnings TO 'jeopardyclient'@'localhost';
GRANT EXECUTE ON FUNCTION jeopardydb.total_player_winnings TO 'jeopardyclient'@'localhost';
GRANT EXECUTE ON FUNCTION jeopardydb.total_season_winnings TO 'jeopardyclient'@'localhost';
FLUSH PRIVILEGES;