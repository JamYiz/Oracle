Alter session set container =zyfinal;
Create user ZY IDENTIFIED BY abc;
Grant dba to ZY;

create tablespace final_space1
datafile 'finalspace1.dbf' 
size 150M autoextend on next 50m maxsize unlimited;

create tablespace final_space2
datafile 'finalspace2.dbf' 
size 150M autoextend on next 50m maxsize unlimited;

create tablespace final_space3
datafile 'finalspace3.dbf' 
size 150M autoextend on next 50m maxsize unlimited;
create tablespace final_space4
datafile 'finalspace4.dbf' 
size 150M autoextend on next 50m maxsize unlimited;

create table goods (
    goods_no char(5) not null primary key,
    goods_name char(20) not null,
    goods_class char(8),
    goods_info char(10),
    goods_brand char(10),
    intake_price float not null CHECK(intake_price > 0),
    outtake_price float not null CHECK(outtake_price > 0)
)TABLESPACE final_space1;

 create table stock (
    goods_no char(5) not null,
    stock_no char(5) not null,
    size_ char(10),
    position_ char(20),
    instore_time date not null,
   outstock_time date not null,
    outgoods_size char(10),
    CONSTRAINT stock_goods_key foreign key (goods_no) references goods(goods_no)
    )TABLESPACE final_space1;

create table department (
    department_no char(5) not null primary key,
    department_name char(10) not null,
    department_minister char(5) not null,
    phone char(11),
    goods_no char(5),
    CONSTRAINT department_goods_key FOREIGN KEY (goods_no) REFERENCES goods (goods_no)
)TABLESPACE final_space1;

create table promoter (
    promoter_no char(5) not null primary key,
    promoter_name char(10) not null,
    sex char(2) not null CHECK(sex IN ('男','女')),
    department_no char(5) not null,
    birthday date ,
    admission_time date not null,
    salary float not null,
    CONSTRAINT promoter_department_key FOREIGN KEY (department_no) REFERENCES department (department_no))

CREATE TABLE orders 
(
  orders_no CHAR(5 BYTE) NOT NULL primary key 
, orders_info CHAR(15 BYTE) NOT NULL 
, orders_price FLOAT(126) 
, orders_time DATE NOT NULL 
) partition by range (orders_time)
  (
partition p1 values LESS THAN (TO_DATE(' 2018-01-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')) tablespace final_space1,

    partition p2 values LESS THAN (TO_DATE(' 2019-01-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')) tablespace final_space2,

    partition p3 values LESS THAN (TO_DATE(' 2020-01-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')) tablespace final_space3,
    
    partition p4 values LESS THAN (MAXVALUE) tablespace final_space4)

create table customer(
    customer_id char(5) not null primary key,
    customer_name char(10) not null,
    customer_tel  char(11),
    orders_no char(5) not null,
    CONSTRAINT customer_orders_key FOREIGN KEY (orders_no) REFERENCES orders (orders_no)
)TABLESPACE final_space1;



create user user1 IDENTIFIED by 123;
create user user2 IDENTIFIED by 123;
alter user user1 quota unlimited on final_space1;
alter user user2 quota unlimited on final_space1;
grant create session to user1;
grant create session to user2;

create role role1;
create role role2;
grant select any table to role1;
grant select any table to role2;
grant update any table to role2;
grant role1 to user1;
grant role2 to user2;

declare
dt date;
orders_no char(5);
orders_info char(5);
orders_price float;
BEGIN
insert into goods (goods_no,goods_name,goods_class,goods_info,goods_brand,intake_price,outtake_price) values ('1','金龙鱼','日用','食用','金龙鱼',59.9,75.6);
insert into goods (goods_no,goods_name,goods_class,goods_info,goods_brand,intake_price,outtake_price) values ('2','冰红茶','饮料','食用','康师傅',2.3,3.0);
insert into goods (goods_no,goods_name,goods_class,goods_info,goods_brand,intake_price,outtake_price) values ('3','巧克力','休闲','食用','德夫',25.5,35.6);
insert into goods (goods_no,goods_name,goods_class,goods_info,goods_brand,intake_price,outtake_price) values ('4','旺仔牛奶','牛奶','食用','旺仔',32.3,53.4);
insert into goods (goods_no,goods_name,goods_class,goods_info,goods_brand,intake_price,outtake_price) values ('5','徐福记','休闲','食用','徐福记',16.5,55.4);
insert into department (department_no,department_name,department_minister,phone,goods_no) values ('501','日用','zs','110','1');
insert into department (department_no,department_name,department_minister,phone,goods_no) values ('502','酒水','ls','120','2');
insert into department (department_no,department_name,department_minister,phone,goods_no) values ('503','休闲','ww','119','3');
insert into department (department_no,department_name,department_minister,phone,goods_no) values ('504','牛奶','cl','10000','4');
end;

insert into orders 
(orders_no,orders_info,orders_price,orders_time)
select rownum as orders_no,
rownum as orders_info,
trunc(dbms_random.value(0, 100)) as orders_price ,
TO_DATE(' 2018-01-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN') as orders_time
from dual
connect by level <= 50000;
select * from orders;

ALTER USER USER1 IDENTIFIED BY 123;

conn USER1;
update orders set orders_info='zy' where orders_no=41448;
select * from orders;
select count(*) from orders partition(p2);

update orders set orders_info='zy';
select * from orders;

 create or replace PACKAGE MyPack IS
  FUNCTION Get_TOTAL(dt1 char,dt2 char) RETURN NUMBER;
  PROCEDURE get_goods(dt1 char);
END MyPack;

create or replace PACKAGE BODY MyPack IS
FUNCTION Get_TOTAL(dt1 char,dt2 char) RETURN NUMBER
  AS
    N  NUMBER;
    BEGIN
     select sum(orders_price) into N from orders where ORDERS_TIME >= to_date(dt1,'yyyy-mm-dd hh24:mi:ss')
     and ORDERS_TIME <= to_date(dt2,'yyyy-mm-dd hh24:mi:ss');
       RETURN N;
       END;
PROCEDURE get_goods(dt1 char)
  AS
    a1 NUMBER;
    b1 NUMBER;
    c1 NUMBER;
    d1 NUMBER;
    cursor cur is
      select * from goods where GOODS_INFO=dt1;
    begin
      a1 := 0;
      b1 := 0;
      c1 := 0;
      d1 := 0;
      --使用游标
      for v in cur 
 loop
         if v.goods_class = '日用'
	        then a1 := a1 + 1;
         elsif v.goods_class = '饮料'
	        then b1 := b1 + 1;
	     elsif v.goods_class = '休闲'
	        then c1 := c1 + 1;
	     elsif v.goods_class = '牛奶'
	        then d1 := d1 + 1;
	     end if;
     END LOOP;
      DBMS_OUTPUT.PUT_LINE('日用商品种类：' ||  a1);
      DBMS_OUTPUT.PUT_LINE('饮料商品种类：' ||  b1);
      DBMS_OUTPUT.PUT_LINE('休闲商品种类：' ||  c1);
      DBMS_OUTPUT.PUT_LINE('牛奶商品种类：' ||  d1);
    end;
END MyPack;