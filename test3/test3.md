# 实验3：创建分区表

## 实验目的：

掌握分区表的创建方法，掌握各种分区方式的使用场景。

## 实验内容：
- 本实验使用3个表空间：USERS,USERS02,USERS03。在表空间中创建两张表：订单表(orders)与订单详表(order_details)。
- 使用**你自己的账号创建本实验的表**，表创建在上述3个分区，自定义分区策略。
- 你需要使用system用户给你自己的账号分配上述分区的使用权限。你需要使用system用户给你的用户分配可以查询执行计划的权限。
- 表创建成功后，插入数据，数据能并平均分布到各个分区。每个表的数据都应该大于1万行，对表进行联合查询。
- 写出插入数据的语句和查询数据的语句，并分析语句的执行计划。
- 进行分区与不分区的对比实验。


## 查看数据库的使用情况

以下样例查看表空间的数据库文件，以及每个文件的磁盘占用情况。

$ sqlplus system/123@pdborcl

```sql
SQL>SELECT tablespace_name,FILE_NAME,BYTES/1024/1024 MB,MAXBYTES/1024/1024 MAX_MB,autoextensible FROM dba_data_files  WHERE  tablespace_name='USERS';
```

```sql
SQL>SELECT a.tablespace_name "表空间名",Total/1024/1024 "大小MB",
 free/1024/1024 "剩余MB",( total - free )/1024/1024 "使用MB",
 Round(( total - free )/ total,4)* 100 "使用率%"
 from (SELECT tablespace_name,Sum(bytes)free
        FROM   dba_free_space group  BY tablespace_name)a,
       (SELECT tablespace_name,Sum(bytes)total FROM dba_data_files
        group  BY tablespace_name)b
 where  a.tablespace_name = b.tablespace_name;
```
###### 查询情况
![image-20210406222822684](https://raw.githubusercontent.com/JamYiz/photos/master/20210406222829.png)
- autoextensible是显示表空间中的数据文件是否自动增加。
- MAX_MB是指数据文件的最大容量。



## 实验步骤
 ##### 首先创建自己的账号zhangyi_，然后以system身份登录:

```sql
[student@deep02 ~]$sqlplus system/123@localhost/pdborcl
SQL>ALTER USER ZY1 QUOTA UNLIMITED ON USERS;
SQL>ALTER USER ZY1 QUOTA UNLIMITED ON USERS02;
SQL>ALTER USER ZY1 QUOTA UNLIMITED ON USERS03;
SQL>exit
```
 ##### 运行结果
![image-20210406223622138](https://raw.githubusercontent.com/JamYiz/photos/master/20210406223622.png)
 ##### 然后以自己的账号ZY1身份登录,并运行脚本文件test3.sql:
```sql
[student@deep02 ~]$cat test3.sql
[student@deep02 ~]$sqlplus ZY1/123@localhost/pdborcl
SQL>@test3.sql
SQL>exit
```
 ##### 运行结果
![avatar](3.png)
![image-20210406224057633](https://raw.githubusercontent.com/JamYiz/photos/master/20210406224057.png)

```text
该脚本在你的账号下创建了两个分区表，orders（一万行数据），order_details（三万行数据）。
```
##### 以system用户运行：
```sql
set autotrace on

select * from ZY1.orders where order_date
between to_date('2017-1-1','yyyy-mm-dd') and to_date('2018-6-1','yyyy-mm-dd');
```
##### 运行结果
![image-20210406224223049](C:\Users\Mordred\AppData\Roaming\Typora\typora-user-images\image-20210406224223049.png)

```sql
select a.ORDER_ID,a.CUSTOMER_NAME,
b.product_name,b.product_num,b.product_price
from ZY1.orders a.ZY1.order_details b where
a.ORDER_ID=b.order_id and
a.order_date between to_date('2017-1-1','yyyy-mm-dd') and to_date('2018-6-1','yyyy-mm-dd');
```
##### 运行结果
![image-20210406224559457](https://raw.githubusercontent.com/JamYiz/photos/master/20210406224559.png)

