### Index Advisor
- select `pg1` and select Tools / Server /  SQL Profiler / Create Trace
- Enter trace details
- Right-click on database `postgres` on `pg1` and select Query Tool
- Create a table using `create table t_test(id serial, name text);`.
- Generate data using `insert into t_test(name) select 'Test' from generate_series(1,2000000);`
- Retrieve a record using `select id from t_test where id=1234567;`
- Select the SQL Profiler tab and select the query from the log. You can use the filter for this.
- Click on the Table icon in the plan and notice the node type and the cost of the query (10266.67)
- Open the index Advisor (graph icon in the top). Notice the differenc ein Node Type.
- Select the `t_test` table in the Suggested indexes pane and select Ok.
- Run the same query again and find the query in the SQL Profile pane again. Notice the Node Type and the total cost (4.45).