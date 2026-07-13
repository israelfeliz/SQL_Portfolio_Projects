-- Table

CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    balance DECIMAL(10,2)
);

INSERT INTO accounts VALUES
(1,'Alice',3000),
(2,'Bob',1500);

/*
Exercise 1 — Basic Transaction (Atomicity)
Scenario: A customer transfers $500 from Account A to Account B.

Task

Perform the transfer inside one transaction.

Requirements

Deduct 500 from Alice
Add 500 to Bob
Commit

Expected result

Alice = 2500
Bob = 2000
*/
----------------------------------
BEGIN;

UPDATE accounts
SET balance = balance - 500
WHERE account_id = 1;

UPDATE accounts
SET balance = balance + 500
WHERE account_id = 2;

COMMIT;
----------------------------------
/*
Exercise 2 — Rollback

Using the same table.

Scenario

After deducting money from Alice, an unexpected error occurs.

Task
Begin transaction
Deduct 500
Simulate an error
Rollback

*/
--------------------------------
BEGIN;

UPDATE accounts
SET balance = balance - 500
WHERE account_id = 1;

-- An error occurs here

ROLLBACK;
--------------------------------

--  Table

CREATE TABLE employees(
    emp_id INT PRIMARY KEY,
    salary DECIMAL(10,2)
);

INSERT INTO employees VALUES
(1,5000),
(2,6000),
(3,4500);

/*
Exercise 3 — Savepoints
Scenario

A company gives raises.

Task

Inside one transaction

Increase employee 1 salary by 10%.

Create SAVEPOINT.

Increase employee 2 salary by 15%.

Create SAVEPOINT.

Increase employee 3 salary by 50%.

Now rollback only employee 3's change.

Commit.

Expected

Employee 1 updated

Employee 2 updated

Employee 3 unchanged
*/
--------------------------------
BEGIN;

UPDATE employees
SET salary = salary * 1.10
WHERE emp_id = 1;

SAVEPOINT emp1;

UPDATE employees
SET salary = salary * 1.15
WHERE emp_id = 2;

SAVEPOINT emp2;

UPDATE employees
SET salary = salary * 1.50
WHERE emp_id = 3;

ROLLBACK TO SAVEPOINT emp2;

COMMIT;
--------------------------------

-- Table

CREATE TABLE inventory(
    product_id INT PRIMARY KEY,
    quantity INT CHECK(quantity>=0)
);

INSERT INTO inventory VALUES
(1,10);

/*Exercise 4 — Consistency

Task

Try

UPDATE inventory
SET quantity = quantity - 20
WHERE product_id=1;

inside a transaction.

Questions

Does the transaction commit? No
Why? Because it violates a check constraint "CHECK(quantity>=0)"

Goal: Understand Consistency. */
--------------------------------------------
/* Exercise 5 — Isolation (Two Sessions)

Open two SQL terminals.

Session A */

BEGIN;

UPDATE accounts
SET balance=balance-300
WHERE account_id=1;

-- Don't commit.

-- Session B

-- Run

SELECT *
FROM accounts;

-- Questions

-- Can Session B see the new balance? No

-- Why or why not? Because it is uncomitted data. Postgresql is set to 
-- isolation read committed by default. 

-----------------------------------------------------

-- Exercise 6 — Dirty Reads

-- If your DB supports READ UNCOMMITTED

-- Session A

BEGIN;

UPDATE accounts
SET balance=100
WHERE account_id=1;

-- No commit.

-- Session B

-- Set isolation level

-- READ UNCOMMITTED

--Read the account.

-- Questions

-- Can you see the uncommitted value? Postgresql does not support 
-- READ UNCOMMITTED, but in other databases that it is supported, I would
-- be ble to see it.

-- What happens after rollback? I would not be able to see it anymore. 

-------------------------------------------------------------------------

-- Exercise 7 — Repeatable Read

-- Session A

BEGIN;

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT balance
FROM accounts
WHERE account_id = 1;

-- Session B
BEGIN;

UPDATE accounts
SET balance=balance+500
WHERE account_id=1;

COMMIT;

-- Session A

-- Read again.

-- Questions

-- What happens under

-- READ COMMITTED: Under READ COMMITTED, every SELECT reads the latest committed 
-- version of the row. Since Session B committed its change, Session A sees the updated balance.

-- REPEATABLE READ: With REPEATABLE READ, the transaction sees the data as it existed 
-- when the transaction began. Even though another transaction committed a change, 
-- Session A continues to read the original value.

-- This prevents non-repeatable reads.

-----------------------------------------------------------------------

-- Exercise 8 — Phantom Reads

-- Table

CREATE TABLE orders(
    id INT PRIMARY KEY,
    amount DECIMAL(10,2)
);

INSERT INTO orders VALUES
(1,200),
(2,300);

-- Session A

BEGIN;

SELECT *
FROM orders
WHERE amount>100;

-- Session B
BEGIN;

INSERT INTO orders
VALUES (3,500);

COMMIT;

-- Session A

-- Run the SELECT again.

Questions

-- Does a new row appear?

Test under

-- READ COMMITTED: The new row appears
-- REPEATABLE READ: The new row does not appear
-- SERIALIZABLE: ERROR:  current transaction is aborted, commands ignored until end of transaction block 

-----------------------------------------------------------

-- Exercise 9 — Deadlock

-- Create

CREATE TABLE products(
    id INT PRIMARY KEY,
    stock INT
);

INSERT INTO products VALUES
(1,100),
(2,200);

-- Session A

BEGIN;

UPDATE products
SET stock=90
WHERE id=1;

-- Don't commit.

-- Session B

BEGIN;

UPDATE products
SET stock=190
WHERE id=2;

-- Now

-- Session A

UPDATE products
SET stock=180
WHERE id=2;

-- Session B

UPDATE products
SET stock=80
WHERE id=1;