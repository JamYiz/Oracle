# oracle
## 实验目的

  分析SQL执行计划，执行SQL语句的优化指导。理解分析SQL语句的执行计划的重要作用。

## 实验内容

- 对Oracle12c中的HR人力资源管理系统中的表进行查询与分析。

- 首先运行和分析教材中的样例：本训练任务目的是查询两个部门('IT'和'Sales')的部门总人数和平均工资，以下两个查询的结果是一样的。但效率不相同。

- 设计自己的查询语句，并作相应的分析，查询语句不能太简单。
## 实验步骤
### 对Oracle12c中的HR人力资源管理系统中的表查询分析：

利用创建索引后的查询语句1查询：

```SQL
set autotrace on

SELECT d.department_name,count(e.job_id)as "部门总人数",
avg(e.salary)as "平均工资"
from hr.departments d,hr.employees e
where d.department_id = e.department_id
and d.department_name in ('IT','Sales')
GROUP BY d.department_name;
```

运行结果如下：

![image-20210315091619324](https://raw.githubusercontent.com/JamYiz/photos/master/20210315114153.png)

语句统计信息如下：

![image-20210315094116026](https://raw.githubusercontent.com/JamYiz/photos/master/20210315114200.png)

![image-20210315094446276](https://raw.githubusercontent.com/JamYiz/photos/master/20210315114212.png)

### 教材样例分析

1. 教材样例如下：

   - 查询1：

   ```SQL
   set autotrace on
   
   SELECT d.department_name,count(e.job_id)as "部门总人数",
   avg(e.salary)as "平均工资"
   from hr.departments d,hr.employees e
   where d.department_id = e.department_id
   and d.department_name in ('IT','Sales')
   GROUP BY d.department_name;
   ```

   - 查询2

   ```SQL
   set autotrace on
   
   SELECT d.department_name,count(e.job_id)as "部门总人数",
   avg(e.salary)as "平均工资"
   FROM hr.departments d,hr.employees e
   WHERE d.department_id = e.department_id
   GROUP BY d.department_name
   HAVING d.department_name in ('IT','Sales');
   ```

   由于网络环境较差，重复实验较多。某些步骤无法复现。当用户hr没有统计权限，运行语句报错

   ```text  
   无法收集统计信息, 请确保用户具有正确的访问权限。
   统计信息功能要求向用户授予 v_$sesstat, v_$statname 和 v_$session 的选择权限。
   ```

   此时可以利用`GRANT`语句授予hr权限。

   ```SQL
   GRANT SELECT ON v_$sesstat TO hr;
   GRANT SELECT ON v_$statname TO hr;
   GRANT SELECT ON v_$session TO hr;
   ```

   

   查询语句1分析：

   ![image-20210315104416254](https://raw.githubusercontent.com/JamYiz/photos/master/20210315114216.png)

   由于语句一是全表查询，根据优化指导有：

   ![image-20210315104401447](https://raw.githubusercontent.com/JamYiz/photos/master/20210315114218.png)

   

   对查询1进行优化，添加索引如下：

   ​	![image-20210315104812825](https://raw.githubusercontent.com/JamYiz/photos/master/20210315114221.png)

   

   此处仅贴出查询2：

   ![image-20210315094927197](https://raw.githubusercontent.com/JamYiz/photos/master/20210315114225.png)

   ### 查询语句设计

   查询shipping部门的员工编号以及对应的工作编号（已创建索引）。

   ```sql
   set autotrace on
   SELECT d.department_name,e.EMPLOYEE_id,e.job_id
   from hr.departments d,hr.employees e
   where d.department_id = e.department_id
   and d.department_name in ('Shipping')
   GROUP BY department_name,e.EMPLOYEE_id,e.job_id;
   ```

   ![image-20210315110201060](https://raw.githubusercontent.com/JamYiz/photos/master/20210315114230.png)

   

   

