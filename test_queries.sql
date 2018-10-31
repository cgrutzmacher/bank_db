CALL get_user_transactions("BruceLee", TRUE);
SELECT RAND()*100;
CALL generate_random_transactions(100);
SELECT (FLOOR(1+ RAND()*100));
SELECT ELT(FLOOR(RAND()*2)+1, 'WITHDRAW', 'DEPOSIT');
SELECT FLOOR(1+RAND()*(SELECT COUNT(*) FROM bank.Accounts));
INSERT INTO bank.Transactions VALUES
		(NULL, (FLOOR(1+ RAND()*100)), ELT(FLOOR(RAND()*2)+1, 'WITHDRAW', 'DEPOSIT'), get_random_date(25), FLOOR(1+RAND()*(SELECT COUNT(*) FROM Accounts)));
        
CALL get_first_name(@first_name);
SELECT @first_name;

CALL generate_random_accounts(25);
SELECT get_first_name('');
SET @account_holder = CONCAT(get_first_name(@first_name), ' ', get_last_name(@last_name));