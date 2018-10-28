DROP DATABASE IF EXISTS bank;
CREATE DATABASE bank;
USE bank;

CREATE TABLE Accounts (
	ID					INT				PRIMARY KEY		AUTO_INCREMENT,
	ACCOUNT_HOLDER		VARCHAR(50)		NOT NULL,
	BALANCE				decimal(50,2)	NOT NULL,
	FEES				decimal(50,2)	NOT NULL,
	USERNAME			varchar(15)		NOT NULL		UNIQUE
);

CREATE TABLE Transactions (
	ID					INT				PRIMARY KEY		AUTO_INCREMENT,
	AMOUNT				DECIMAL(50.2)	NOT NULL,
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
	IF NEW.trans_type = "WITHDRAW" THEN
		UPDATE accounts SET balance =
		(@curBal - NEW.amount)
        WHERE ID = NEW.account_id;
	ELSE 
		UPDATE accounts SET balance =
		(@curBal + NEW.amount)
        WHERE ID = NEW.account_id;
	END IF;

END; //

DELIMITER ;

/*
going to add functionality to the trigger. 
IDEA: if withdraw draws below the account holders balance charge their account a fee of 35$
during query subtract the fees to their account balance so it displays their actual balance. 
ADD: "PAYMENT" option that allows them to pay their fees ( this depends on how i decide to do the above idea )
ADD: OVERDRAFT_PROTECTION if user overdraws their account and they have overdraft protection they won't get the fee
*/

INSERT INTO Accounts VALUES
(1, "John Smith", 7500, 230, "JohnSmith"),
(2, "Jeff Lebowski", 5.75, 300, "TheDude"),
(3, "Johnny Cash", 45000, 5.50, "ManInBlack"),
(4, "Bruce Lee", 6500, 500, "BruceLee"),
(5, "John Smith", 476, 10, "LovesFishing");

INSERT INTO Transactions VALUES
(NULL, 500, "DEPOSIT", 5),
(NULL, 3.50, "WITHDRAW", 1),
(NULL, 15, "DEPOSIT", 1),
(NULL, 4.78, "WITHDRAW", 2),
(NULL, 1750, "DEPOSIT", 3),
(NULL, 260, "WITHDRAW", 3),
(NULL, 399.99, "WITHDRAW", 4),
(NULL, 75, "WITHDRAW", 5);