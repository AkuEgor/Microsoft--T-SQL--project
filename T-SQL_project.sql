go
set quoted_identifier on
go
drop trigger tr1
drop trigger tr2
drop trigger tr3
drop trigger tr4
drop procedure recentFixes
drop procedure customerCars
drop procedure incomeBetween
drop procedure increaseSalary

 DROP  TABLE inst;
DROP TABLE parts;
DROP TABLE task;
DROP TABLE tow;
DROP TABLE ORDERS;
DROP TABLE cus;
DROP TABLE cars;

CREATE TABLE CARS
(IDCAR  smallint not null,
  Plates varchar(10),
  C_MODEL varchar(10),
  IDOwner smallint not null,
  P_YEAR smallint,
  Color varchar(10),
  CONSTRAINT CARS_PK PRIMARY KEY(IDCAR));
  
  create table CUS(
IDOwner smallint,
  PhnNumr bigint,
  DrLse smallint,
  CUS_Name varchar(8),
  Surname varchar(8),
  CONSTRAINT CUS_PK PRIMARY KEY(IDOwner));
   
  
  CREATE TABLE ORDERS
(ORDER_ID float,
  OIDCAR smallint,
  OIDowner smallint,
  CodeWork smallint,
  DATES datetime,
  CONSTRAINT ORDERS_PK PRIMARY KEY(ORDER_ID),
 CONSTRAINT ORDERS_cars_FK FOREIGN KEY(OIDCAR) REFERENCES CARS (IDCAR),
 CONSTRAINT ORDERS_owner_FK FOREIGN KEY(OIDowner) REFERENCES CUS (IDOwner));

  create table TOW
(WORKCODE float,
  WorkCost decimal(5,2),
  DESCRIPT varchar(15),
  CONSTRAINT TOW_PK PRIMARY KEY(WORKCODE));

create table TASK
(ORNUM float,
 WRKCODE float,
 CONSTRAINT TASK_PK PRIMARY KEY(ORNUM),
  CONSTRAINT TASK_ORDERS_FK FOREIGN KEY(ORNUM) REFERENCES ORDERS (ORDER_ID),
  CONSTRAINT TASK_TOW_FK FOREIGN KEY (WRKCODE) REFERENCES TOW (WORKCODE));
  
  
  create table PARTS
(PIDS float,
  LOC varchar(10),
  P_NAME VARCHAR(20),
  Pprice decimal(10,2),
  Stock decimal(20),
  CONSTRAINT PIDS_PK PRIMARY KEY(PIDS));
  
  
  create table INST
(ORnumB float,
  PID float,
CONSTRAINT INST_PK PRIMARY KEY(ORnumB),
CONSTRAINT INST_FK FOREIGN KEY(PID) REFERENCES PARTS (PIDS),
 CONSTRAINT INSTL_ORDERS_PK FOREIGN KEY (ORnumB) REFERENCES ORDERS (ORDER_ID));


 
insert into CARS VALUES (20,'OO-00100','Prado 200',1,2017,'BLACK');
insert into CARS VALUES (19,'GF-52969','Saburban',2,2010,'YELLOW');
insert into CARS VALUES (17,'QB-13498','Prius',3,2018,'RED'); 
insert into CARS VALUES (16,'CD-24575','VESTA',4,2015,'GREY'); 
insert into CARS VALUES (15,'LS-75252','ASTRA',5,2010,'BLUE'); 
 
insert into CUS VALUES (1,10001,4513,'John','Dylan');
insert into CUS VALUES (2,20002,9058,'Kendrek','Kriko');
insert into CUS VALUES (3,30003,6784,'Danila','Poper'); 
insert into CUS VALUES (4,40004,9274,'POOPKA','MUMBA'); 
insert into CUS VALUES (5,50005,1037,'KARISH','PHIL'); 
 
insert into ORDERS VALUES (001,20,1,888,'2018-06-05');
insert into ORDERS VALUES (002,19,2,777,'2018-01-29');
insert into ORDERS VALUES (003,17,3,666,'2018-12-20'); 
insert into ORDERS VALUES (004,16,4,555,'2018-07-01'); 
insert into ORDERS VALUES (005,15,5,444,'2018-06-16'); 
 
insert into TOW VALUES (888,290.50,'wheels');
insert into TOW VALUES (777,643.43,'new_liquid');
insert into TOW VALUES (666,411.84,'rebuild'); 
insert into TOW VALUES (555,89.24,'new window'); 
insert into TOW VALUES (444,411.83,'engine check'); 
 
insert into TASK VALUES (001,888);
insert into TASK VALUES (002,777);
insert into TASK VALUES (003,666); 
insert into TASK VALUES (004,555); 
insert into TASK VALUES (005,444); 
 
insert into PARTS VALUES (601,'BERLIN','TURBO',182.00,1);
insert into PARTS VALUES (602,'MINSK','CRANCK SHAFT',78.50,4);
insert into PARTS VALUES (603,'PARIS','RIMS',314.99,9); 
insert into PARTS VALUES (604,'WARSAW','LOCK',284.27,7); 
insert into PARTS VALUES (605,'GDANSK','CARBONFIBER',234.89,3); 

insert into INST VALUES (001,601);
insert into INST VALUES (002,602);
insert into INST VALUES (003,603);
insert into INST VALUES (004,604);
insert into INST VALUES (005,605);




						-- ===== Triggers ===== --



  -- Outputs number of vehicle parts after insert/delete
create  trigger TR4
on Parts
after insert, delete
as
  declare @partsCount int = (select count(*) from parts);
  print 'Now there are ' + cast(@partsCount as varchar) + ' parts';
go

insert into PARTS VALUES (610,'MINSK','CRANCK SHAFT',78.50,4);



-- ===== Trigger for update ===== -- 
--Price Updater Trigger, if more then allowed then RaisError--
create trigger TR3 
on parts after update
as
declare @newPrice numeric(3);
begin
select @newPrice = i.Pprice from inserted i;
if (@newPrice >500)
begin rollback;
raiserror('price is too high',1,2);
end;
end;
 
update parts set pprice = 15 where PIDS = 601;
select * from parts



    -- ===== Trigger for delete ===== -- 
-- After Deleting a row, Trigger will show the amount of rows left--
  create trigger TR2 on orders for delete
as
declare @counter int
begin
select @counter = count(ORDER_ID) from orders;
print 'now we have ' +RTRIM(@counter)+ ' orders';
end;


delete from orders
where ORDER_ID = 4






						-- ===== Procedures ===== --

-- Return result set of cars of certain person
create procedure customerCars
  @customerId int
as
  select cm.IDCAR, cm.PLATES, cm.C_MODEL, cm.IDOwner, cm.P_YEAR, Color
  from Cars cm
  inner join orders c on cm.IDCAR = c.OIDCAR
  where c.OIDowner = @customerId;
go

exec customerCars 3;


-- Return income between certain dates  via output
create  procedure incomeBetween
  @startDate datetime,
  @endDate datetime,
  @income money output
as
  set nocount on;
		select @income = sum(T.WORKCOST)  
FROM ORDERS O, TOW T,  TASK D
WHERE  T.WORKCODE = D.WRKCODE AND D.ORNUM = O.ORDER_ID
 and O.dates >= @startDate and
        O.dates <= @endDate;

return
go

declare @incomeTotal money;
exec incomeBetween '2018-01-05 00:00:00.000', '2018-08-09 00:00:00.000', @income = @incomeTotal output;
print 'Income total: ' + cast(@incomeTotal as varchar);



-- Return result set of needed number of most recent fixes
create procedure recentFixes
  @recentNum int = 3
as
  SELECT TOP(@recentNum) * FROM ORDERS;
go

EXEC dbo.recentFixes 4;



-- Increase price of parts  with price lower then certain value by needed number of percent
-- 0 if successful
-- 1 if one of params is negative
-- 2 if no employees in the table

create procedure increaseSalary
  @minSum smallmoney,
  @incrPercent smallint
as
   if @minSum < 0 or @incrPercent < 0
     begin
       print 'Values cannot be negative!'
       return(1)
     end

   declare @count int = (select count(*) from parts);
   if @count = 0
     begin
       print 'No parts in the table!'
       return(2)
     end

    update parts
    set pprice += (pprice * @incrPercent) / 100
    where pprice <= @minSum;

   return(0);
go 

  declare @returnCode int;
  execute @returnCode = increaseSalary 200, 60;
  print cast(@returnCode as varchar);

  select * from parts;
		


			 ---====	Thank you for your attetion		====---






























/*




			 -- ===== Trigger for insert ===== --
 --insert Trigger for table Customer, adds new values to new ID's--
    create trigger TR1 on CUS after insert
  as
  declare @newId int,
  @phoNum numeric(9),
  @DrLses numeric(9),
  @Cnam char(14),
  @Csurnam char(14)
  begin
  select @newId = isnull(max(IDOwner)+2, 2) from cus;
  select @phoNum = i.PhnNumr from inserted i;
  select @DrLses = i.DrLse from inserted i;
  select @Cnam = i.CUS_Name from inserted i;
  select @Csurnam = i.Surname from inserted i;
  end;

  insert into CUS VALUES (6,30003,6784,'Danila','Poper'); 
  select * from CUS;
  drop trigger tr1