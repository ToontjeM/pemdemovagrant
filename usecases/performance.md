### Performance diagnostics
- Select pg1 and from the top meno, select the overall dashboard.
- Open a teminal and get the password for user `dba` using `taexec show-password pemdemovagrant dba`.
- In the same terminal, generate traffic using `pgbench -h localhost -p 5444 -i -U dba postgres` and then `pgbench -h localhost -p 5444 -T 100 -c 10 -j 2 -U dba postgres`. 
- Select Tools / Server / Performance diagostics and walk through the Wait events dertails options.