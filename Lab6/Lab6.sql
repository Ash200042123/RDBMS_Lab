drop table logBook;
drop table RegSims;
drop table PLANS;
drop table CUSTOMER;


-- 2a--
create table Customer
(
    CID     varchar(20) primary key,
    name    varchar(20),
    DOB     timestamp,
    Address varchar(30),
    time timestamp
);

create table plans
(
    PID            int primary key,
    name           varchar(20),
    charge_per_min number
);

create table RegSims
(
    SID int primary key,
    CID varchar(20),
    PID int,
    MobNumber varchar(20) unique,
    constraint fk_regsim_customer foreign key (CID) references Customer(CID),
    constraint fk_regsim_plan foreign key (PID) references plans(PID)
);

create table logBook
(
    Call_id int,
    SID     int,
    begin   timestamp,
    end     timestamp,
    charge  number,
    constraint fk_logBook foreign key (SID) references RegSims(SID)
);


-- 2b--
create or replace function calc_charge (mob int, beg timestamp, ed timestamp)
return number
As
    charge plans.charge_per_min%type;
    duration number;
    rduration number;
begin
    select charge_per_min into charge
    from RegSims natural join plans t
    where MobNumber=mob;

    duration:=(ed - beg)/60;
    rduration:=round(duration);

    if duration > rduration then
        duration:=round(duration)+1;
    end if;

    charge:=charge*duration;

    return charge;
end;




-- 2c--
create or replace function
Generate_ID
return varchar
As
    maxID varchar(20);
    editdate varchar(20);
    editnum varchar(20);
begin
    select CID into maxID
        from CUSTOMER
        where ROWNUM<=1
        order by time desc;
    editdate:=TO_CHAR(sysdate, 'yyyymmdd');
    if(maxID = null) then
        return editdate||'.00000001';
    end if;

    editnum:=to_number(substr(maxID,10,8))+1;
    return editdate||'.'||to_char(LPAD(editnum,8,'0'));
end;
                                

CREATE OR REPLACE TRIGGER new_CID
before INSERT ON logBook
FOR EACH ROW
declare
    new_id logBook.Call_id%type;
BEGIN
    new_id:=Generate_ID();
    :new.Call_id:=new_id;
END ;















drop table transaction;
drop table misconducts;
drop table student;

create table student
(
    ID   int primary key,
    name varchar(20),
    prog varchar(20),
    year varchar(20),
    cgpa number
);

create table misconducts
(
    id          int,
    time        date,
    description varchar(100),
    foreign key (id) references student(id)
);



create table transaction
(
    id   int,
    time date,
    amount_paid number,
    foreign key (id) references student (id)
);

create or replace procedure do_transaction(id student.id%type,amount transaction.amount_paid%type)
As
begin
    insert into transaction values(id,sysdate,amount);
end;

create or replace function Get_scholarship_Num(MsAmount number, SAmount number)
return varchar
As
    cnt number default 0;
    MAmount number;
    idcount number;
    cursor c is
        select ID
        from student
        where student.prog='SWE' and student.year=20 and cgpa>=3.5
        minus (select id from misconducts)
        order by cgpa desc;
begin
    MAmount:=MsAmount;
    select count(id) into idcount
    from student
    where student.prog='SWE' and student.year=20 and cgpa>=3.5
    minus
    (select id from misconducts);

    for rows in c loop
        exit when (MAmount-SAmount)<0;
        do_transaction(rows.id,SAmount);
        MAmount:=MAmount-SAmount;
        cnt:=cnt+1;
    end loop;

    return to_char(idcount-cnt) || to_char(cnt);

end;
