

/*
NOTE: MUST RUN random_names_db.sql first before this database will execute.

NOTE: in order to run FUNCTION get_random_date you must first run command
SET GLOBAL log_bin_trust_function_creators = 1;
then edit
C:\ProgramData\MySQL\MySQL Server 8.0\my.ini and add the flag
log_bin_trust_function_creators=1
finally restart mysql service then run sql script again

CALL get_user_transactions((SELECT username FROM accounts ORDER BY RAND() LIMIT 1), FALSE); will provide you with a random users transactions
CALL get_user_transactions('', TRUE); will provide you with all transactions from all users ordered by name then date

convenience procedure add_check_user added to create new user manually if username doesn't exist
or to add a transaction if the user already exists. 
CALL add_check_user("John Smith", 50000, 'JohnnyBoy', 500, 'WITHDRAW');
CALL add_check_user("John Smith", 50000, 'JohnSmith', 500, 'DEPOSIT');

CALL generate_random_accounts(25); this function will randomly generate desired number of new user accounts
CALL generate_random_transactions(100); this function will generate desired number of transactions for randomly users

*/



DROP DATABASE IF EXISTS bank;
CREATE DATABASE bank;
USE bank;

CREATE TABLE Accounts (
	ID					INT				PRIMARY KEY		AUTO_INCREMENT,
	ACCOUNT_HOLDER		VARCHAR(50)		NOT NULL,
	BALANCE				decimal(9,2)	NOT NULL,
	FEES				decimal(9,2)	NOT NULL,
	USERNAME			varchar(50)		NOT NULL		UNIQUE
);

CREATE TABLE Transactions (
	ID					INT				PRIMARY KEY		AUTO_INCREMENT,
	AMOUNT				DECIMAL(9,2)	NOT NULL,
	TRANS_TYPE			VARCHAR(8)		NOT NULL,
    TRANS_DATE			DATE			NOT NULL,
	ACCOUNT_ID			INT				NOT NULL,
	FOREIGN KEY (ACCOUNT_ID) REFERENCES Accounts (ID)
);

DELIMITER //

CREATE TRIGGER update_account_balance
AFTER INSERT
   ON Transactions FOR EACH ROW 
BEGIN

	SET @curBal = (SELECT balance FROM accounts WHERE ID = NEW.account_id);
    SET @curFees = (SELECT fees FROM accounts WHERE ID = NEW.account_id);
    
	IF NEW.trans_type = "WITHDRAW" THEN
    
		IF (@curBal - NEW.amount) < 0 THEN
			UPDATE accounts SET 
            balance = (@curBal - NEW.amount),
            fees = (fees + 35)
			WHERE ID = NEW.account_id;
            
		ELSE
			UPDATE accounts SET 
            balance = (@curBal - NEW.amount)
			WHERE ID = NEW.account_id;        
		END IF;
        
	ELSE
            
		IF @curFees > 0 AND NEW.amount <= @curFees THEN
			UPDATE accounts SET
            fees = (@curFees - NEW.Amount)
            WHERE ID = NEW.account_id;
            
		ELSEIF @curFees > 0 AND NEW.amount > @curFees THEN
			UPDATE accounts SET
            fees = 0,
            balance = (@curBal + NEW.amount) - fees
            WHERE ID = NEW.account_id; 
            
        ELSE
			UPDATE accounts SET 
			balance = (@curBal + NEW.amount)
			WHERE ID = NEW.account_id;
		END IF;
        
	END IF;

END; //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE add_check_user
(IN account_hol VARCHAR(50), bal DECIMAL(9,2), uname VARCHAR(15), amnt DECIMAL(9,2), transaction_type VARCHAR(8))
BEGIN

	IF EXISTS(SELECT id FROM accounts WHERE uname = username) THEN
		SET @uid = (SELECT id FROM accounts WHERE uname = username);
        INSERT INTO Transactions VALUES
        (NULL, amnt, transaction_type, get_random_date(5), @uid);        
        
	ELSE
		INSERT INTO accounts VALUES
        (NULL, account_hol, bal, 0, uname);
        SET @last_inserted_id = LAST_INSERT_ID();
        INSERT INTO Transactions VALUES
        (NULL, amnt, transaction_type, get_random_date(5), @last_inserted_id);        
	END IF;

END; //

DELIMITER ;


DELIMITER //

CREATE PROCEDURE get_user_transactions
(IN uname VARCHAR(15), IN get_all_users BOOLEAN)
BEGIN
	
    IF NOT get_all_users THEN
		SELECT account_holder, Transactions.amount, Transactions.trans_type, Transactions.trans_date FROM accounts
		LEFT OUTER JOIN Transactions ON Transactions.account_id=accounts.id
		WHERE accounts.username = uname
		ORDER BY trans_date DESC;
        
	ELSE 
		SELECT account_holder, Transactions.amount, Transactions.trans_type, Transactions.trans_date FROM accounts
		LEFT OUTER JOIN Transactions ON Transactions.account_id=accounts.id
        ORDER BY account_holder ASC, trans_date DESC;
		
    END IF;

END; //

DELIMITER ;


DELIMITER //

CREATE FUNCTION get_random_date
(start_year INT)
RETURNS DATE
NOT DETERMINISTIC
BEGIN
	DECLARE rand_date DATE;
    SET rand_date = (SELECT CURDATE() - INTERVAL RAND()*start_year YEAR - INTERVAL RAND()*365 DAY);
    RETURN rand_date;
    
END; //

DELIMITER ;

DELIMITER //

CREATE FUNCTION get_first_name
(first_name VARCHAR(25))
RETURNS VARCHAR(25)
NOT DETERMINISTIC
BEGIN
		SET @max_users = (SELECT COUNT(*) FROM names.firstName);
        SET first_name =  (SELECT name FROM names.firstname ORDER BY RAND() LIMIT 1);
		
        RETURN first_name;
        
END; //

DELIMITER ;

DELIMITER //

CREATE FUNCTION get_last_name
(last_name VARCHAR(25))
RETURNS VARCHAR(25)
NOT DETERMINISTIC
BEGIN
		SET @max_users = (SELECT COUNT(*) FROM names.firstName);
        SET last_name =  (SELECT name FROM names.lastname ORDER BY RAND() LIMIT 1);
        
        RETURN last_name;

END; //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE generate_random_transactions
(IN num_of_transactions INT)
BEGIN

	SET @i = 0;
    SET @user_count = (SELECT COUNT(*) FROM Accounts);
    WHILE @i <= num_of_transactions DO
		INSERT INTO Transactions VALUES
		(NULL, (FLOOR(1+ RAND()*100)), ELT(FLOOR(RAND()*2)+1, 'WITHDRAW', 'DEPOSIT'), get_random_date(5), FLOOR(1+RAND()*@user_count));
        SET @i = @i+1;
	END WHILE;

END; //

DELIMITER ;


DELIMITER //

CREATE PROCEDURE generate_random_accounts
(IN num_of_accounts INT)
BEGIN
	SET @i = 0;
    
    WHILE @i <= num_of_accounts DO
		SET @first_name = get_first_name('');
        SET @last_name = get_last_name('');
    
		INSERT INTO Accounts VALUES
			(NULL, CONCAT(@first_name, ' ', @last_name), (FLOOR(1+ RAND()*10000)), 0, CONCAT(@first_name, @last_name));
            
		SET @i = @i+1;
    
    END WHILE;


END; //

DELIMITER ;

CALL generate_random_accounts(25);
CALL generate_random_transactions(100);



