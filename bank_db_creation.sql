DROP DATABASE IF EXISTS bank;
CREATE DATABASE bank;
USE bank;

CREATE TABLE Accounts (
	ID					INT				PRIMARY KEY		AUTO_INCREMENT,
	ACCOUNT_HOLDER		VARCHAR(50)		NOT NULL,
	BALANCE				decimal(9,2)	NOT NULL,
	FEES				decimal(9,2)	NOT NULL,
	USERNAME			varchar(15)		NOT NULL		UNIQUE
);

CREATE TABLE Transactions (
	ID					INT				PRIMARY KEY		AUTO_INCREMENT,
	AMOUNT				DECIMAL(9,2)	NOT NULL,
	TRANS_TYPE			VARCHAR(8)		NOT NULL,
	ACCOUNT_ID			INT				NOT NULL,
	FOREIGN KEY (ACCOUNT_ID) REFERENCES Accounts (ID)
);

DELIMITER //

CREATE TRIGGER update_account_balance
AFTER INSERT
   ON Transactions FOR EACH ROW 
BEGIN

	SET @curBal = (SELECT balance from accounts where ID = NEW.account_id);
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
            
		IF @curFees > 0 AND new.amount <= @curFees THEN
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
(IN account_hol VARCHAR(50), bal decimal(9,2), uname varchar(15), amnt DECIMAL(9,2), transaction_type VARCHAR(8))
BEGIN

	IF EXISTS(SELECT id from accounts where uname = username) THEN
		SET @uid = (SELECT id from accounts where uname = username);
        INSERT INTO Transactions VALUES
        (NULL, amnt, transaction_type, @uid);        
        
	ELSE
		INSERT INTO accounts VALUES
        (NULL, account_hol, bal, 0, uname);
        SET @last_inserted_id = LAST_INSERT_ID();
        INSERT INTO Transactions VALUES
        (NULL, amnt, transaction_type, @last_inserted_id);        
	END IF;

END; //

DELIMITER ;


DELIMITER //

CREATE PROCEDURE get_user_transactions
(IN uname varchar(15))
BEGIN

	SELECT account_holder, Transactions.amount, Transactions.trans_type FROM accounts
	LEFT OUTER JOIN Transactions ON Transactions.account_id=accounts.id
	WHERE accounts.username = uname;

END; //

DELIMITER ;


INSERT INTO Accounts VALUES
(1, "John Smith", 7500, 0, "JohnSmith"),
(2, "Jeff Lebowski", 5.75, 0, "TheDude"),
(3, "Johnny Cash", 45000, 0, "ManInBlack"),
(4, "Bruce Lee", 6500, 0, "BruceLee"),
(5, "John Smith", 476, 0, "LovesFishing");

INSERT INTO Transactions VALUES
(NULL, 500, "DEPOSIT", 5),
(NULL, 3.50, "WITHDRAW", 1),
(NULL, 15, "DEPOSIT", 1),
(NULL, 4.78, "WITHDRAW", 2),
(NULL, 1750, "DEPOSIT", 3),
(NULL, 260, "WITHDRAW", 3),
(NULL, 399.99, "WITHDRAW", 4),
(NULL, 75, "WITHDRAW", 5);


/*
convenience procedure added to create new user if username doesn't exist
or to add a transaction if the user already exists. 
here's two examples:
CALL add_check_user("John Smith", 50000, 'JohnnyBoy', 500, 'DEPOSIT');
CALL add_check_user("John Smith", 50000, 'JohnSmith', 500, 'DEPOSIT');
*/

