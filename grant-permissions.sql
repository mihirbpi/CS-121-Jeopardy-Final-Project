CREATE USER 'jeopardyadmin'@'localhost' IDENTIFIED BY 'adminpw';
CREATE USER 'jeopardyclient'@'localhost' IDENTIFIED BY 'clientpw';

-- Can add more users or refine permissions
GRANT ALL PRIVILEGES ON jeopardydb.* TO 'jeopardyadmin'@'localhost';
GRANT SELECT ON jeopardydb.* TO 'jeopardyclient'@'localhost';
FLUSH PRIVILEGES;