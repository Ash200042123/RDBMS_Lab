DROP TABLE TRANSACTION;
DROP TABLE BALANCE;
DROP TABLE ACCOUNT_PROPERTY;
DROP TABLE ACCOUNT;

alter table ACCOUNT
drop constraint PK_ACCOUNT_NUMBER;








CREATE TABLE ACCOUNT_PROPERTY
(
    ID NUMBER,
    NAM VARCHAR2(50),
    PROFIT_RATE NUMBER,
    GRACE_PERIOD NUMBER,
    CONSTRAINT PK_ACCOUNT_PROPERTY PRIMARY KEY(ID)
);


CREATE TABLE ACC
(
    ID NUMBER,
    NAM VARCHAR2(50),
    ACC_CODE NUMBER,
    OPENING_DATE DATE,
    LAST_DATE_INTEREST DATE,
    CONSTRAINT PK_ACCOUNT PRIMARY KEY(ID),
    CONSTRAINT FK_ACCOUNT FOREIGN KEY(ACC_CODE) REFERENCES ACCOUNT_PROPERTY(ID)
);


CREATE TABLE TRANSACTION
(
    TID NUMBER,
    ACC_NO NUMBER,
    AMOUNT NUMBER,
    TRANSACTION_DATE DATE,
    CONSTRAINT PK_TRANSACTION PRIMARY KEY(TID),
    CONSTRAINT FK_TRANSACTION FOREIGN KEY(ACC_NO) REFERENCES ACC(ID)
);


CREATE TABLE BALANCE
(
    ACC_NO NUMBER,
    PRINCIPAL_AMNT NUMBER,
    PROFIT_AMNT NUMBER,
    CONSTRAINT PK_BALANCE PRIMARY KEY(ACC_NO),
    CONSTRAINT FK_BALANCE FOREIGN KEY(ACC_NO) REFERENCES ACC(ID)
);


-- A
CREATE or replace FUNCTION curr_balance(ACCOUNT_NO NUMBER)
RETURN NUMBER
AS
    balance NUMBER;
    initial NUMBER;
BEGIN
    SELECT SUM(TRANSACTION.AMOUNT) INTO balance
    FROM TRANSACTION
    WHERE TRANSACTION.ACC_NO=ACCOUNT_NO;

    SELECT PRINCIPAL_AMNT INTO initial
    FROM BALANCE
    WHERE BALANCE.ACC_NO= ACCOUNT_NO;

    balance := balance+initial;

    return balance;
END;
/


-- B
CREATE OR REPLACE FUNCTION calc_profit(ACCOUNT_NO NUMBER, OUT prof:=0, OUT balance_before, OUT balance_after)
AS 
    typ NUMBER;
    prof_rate NUMERIC(6,2);
    open_date DATE;
    curr_date DATE;
    duration NUMBER;
BEGIN
    SELECT PRINCIPAL_AMNT INTO balance_before
    FROM BALANCE
    WHERE BALANCE.ACC_NO= ACCOUNT_NO;

    SELECT ACCOUNT_PROPERTY.ID,ACCOUNT_PROPERTY.PRODIT_RATE, ACC.OPENING_DATE INTO typ,prof_rate,open_date
    FROM ACCOUNT_PROPERTY, ACC
    WHERE ACC.ACC_NO= ACCOUNT_NO AND ACC.ACC_CODE=ACCOUNT_PROPERTY.ID;

    SELECT SYSDATE INTO curr_date FROM DUAL;

    SELECT MONTHS_BETWEEN(curr_date,open_date) INTO duration FROM DUAL;

    IF typ==2002 and duration>=1 THEN
        prof:= ((prof_rate)/100)*balance_before;
        balance_after:= balance_before+prof;
    ELSE IF typ==3003 duration>=4 THEN
        prof:= ((prof_rate)/100)*balance_before;
        balance_after:= balance_before+prof;
    ELSE IF typ==4004 duration>=6 THEN
        prof:= ((prof_rate)/100)*balance_before;
        balance_after:= balance_before+prof;
    ELSE IF typ==5005 duration>=12 THEN
        prof:= ((prof_rate)/100)*balance_before;
        balance_after:= balance_before+prof;
    END IF;

END;
/




-- C

CREATE OR REPLACE PROCEDURE calc_all_profit(IN account_no NUMBER)
AS
    prof NUMERIC(6,2);
    curr_date DATE;
    duration NUMBER;
    typ NUMBER;
    prof_rate NUMERIC(6,2);
    ac NUMBER;
    open_date DATE;
    cursor c1 is 
    SELECT ACCOUNT_PROPERTY.ID AS ID,ACCOUNT_PROPERTY.PROFIT_RATE, ACC.OPENING_DATE , ACC.ID AS accc
    INTO typ,prof_rate,open_date
    FROM ACCOUNT_PROPERTY, ACC
    WHERE ACC.ACC_NO= ACCOUNT_NO AND ACC.ACC_CODE=ACCOUNT_PROPERTY.ID;

BEGIN
    OPEN c1;

    SELECT SYSDATE INTO curr_date FROM DUAL;
    FOR accounts in c1
    LOOP
    typ:= account.ID
    prof_rate := account.PROFIT_RATE
    open_date := account.OPENING_DATE
    ac := account.accc
    SELECT MONTHS_BETWEEN(curr_date,open_date) INTO duration FROM DUAL;

        IF typ==2002 and duration>=1 THEN
        prof:= ((prof_rate)/100);
    ELSE IF typ==3003 duration>=4 THEN
        prof:= ((prof_rate)/100);
    ELSE IF typ==4004 duration>=6 THEN
        prof:= ((prof_rate)/100);
    ELSE IF typ==5005 duration>=12 THEN
        prof:= ((prof_rate)/100);
    END IF;

    INSERT INTO TRANSACTION VALUES(101,ac,prof,curr_date);
    END LOOP;

END;
/