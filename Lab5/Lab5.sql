
-- 1 --

CREATE SEQUENCE seq1
MINVALUE 10001
MAXVALUE 99999
START WITH 10001
INCREMENT BY 1
CACHE 20;

CREATE OR REPLACE FUNCTION generate_acc_id(nam VARCHAR2,acc_code NUMBER,opening_date DATE)
RETURN VARCHAR2
AS
    new_acc_id VARCHAR2(50);
    NEW_ID INT;
BEGIN
    SELECT seq1.nextval INTO NEW_ID FROM DUAL;
    new_acc_id:= acc_code||to_char(opening_date,'YYYYMMDD') || '.' || substr(nam,1,3) || '.' || NEW_ID;
    return new_acc_id;
END;
/





-- 2 --

ALTER TABLE ACC DROP COLUMN ID CASCADE CONSTRAINTS;

ALTER TABLE TRANSACTION DROP COLUMN ACC_NO CASCADE CONSTRAINTS;

ALTER TABLE BALANCE DROP COLUMN ACC_NO CASCADE CONSTRAINTS;

ALTER TABLE ACC ADD ID VARCHAR2(30) PRIMARY KEY;

ALTER TABLE TRANSACTION ADD ACC_NO VARCHAR2(30);

ALTER TABLE BALANCE ADD ACC_NO VARCHAR2(30) PRIMARY KEY;

ALTER TABLE TRANSACTION ADD CONSTRAINT FK_TRANSACTION FOREIGN KEY (ACC_NO) REFERENCES ACC(ID);

ALTER TABLE BALANCE ADD CONSTRAINT FK_BALANCE FOREIGN KEY (ACC_NO) REFERENCES ACC(ID);






-- 3 --


CREATE OR REPLACE TRIGGER acc_id_assignment 
BEFORE INSERT ON ACC
FOR EACH ROW
DECLARE
    id ACC.ID%TYPE;
BEGIN
    id:= generate_acc_id(:new.nam,:new.ACC_CODE,:new.OPENING_DATE);
    :new.ID := id;
END;
/



-- 4 --

CREATE OR REPLACE TRIGGER balance_assignment 
AFTER INSERT ON ACC
FOR EACH ROW
DECLARE
    id ACC.ID%TYPE;
BEGIN
    id:= :new.ID;
    INSERT INTO BALANCE VALUES(id, 5000,0);
END;
/




-- 5 --



CREATE OR REPLACE TRIGGER update_balance 
AFTER INSERT ON TRANSACTION
FOR EACH ROW
DECLARE
    amount TRANSACTION.AMOUNT%TYPE;
    acc TRANSACTION.ACC_NO%TYPE;
BEGIN
    amount := :new.AMOUNT;
    acc := :new.ACC_NO;
    UPDATE BALANCE SET PRINCIPAL_AMNT = PRINCIPAL_AMNT+amount
    WHERE BALANCE.ACC_NO=acc;
END;
/


