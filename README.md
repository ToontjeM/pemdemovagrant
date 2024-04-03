# Postgres Enterprise Manager demo

This demo is built for running on Vagrant and is using the Trusted Postgres Architect (TPA) to deploy a 2-node cluster managed by EDB Failover Manager, a Barman server and a PEM server.
The objective of the demo environment is to show the value of Postgres Enterprise Manager.

TPA will deploy the following components:
| Name | IP | Task | Remarks |
| -------- | -------- | -------- | -------- |
| console| 192.168.0.210 | Console | TPA installed |
| pg1| 192.168.0.211 | Postgres primary | PEM agent<br>Backup target<br>Port 5444 open |
| pg2 | 192.168.0.212 | Postgres replica | PEM agent |
| barman | 192.168.0.213 | Barman | PEM agent <br> Backup target<br>EFM witness |
| pemserver | 192.168.0.214 | PEM | Port 443 open |

The environment is currently deployed in a bridged network, hence the IP addresses are allocated in my home network. Adjust the IP addresses to your needs in `Vagrantfile` and `configyml.backup`.

The EFM cluster which is created is called `pemdemovagrant`. 

Status of the EFM cluster can be shown using `docker exec -it pg1 bash -c "/usr/edb/efm-4.7/bin/efm cluster-status pemdemovagrant"`

## Demo prep
Run `00-provision.sh` to provision the Postgres containers (pg1 and pg2), the barman container (barman) and the PEM container (pemserver). This deployment will take appx. 20 minutes to complete.
After successful deployment PEM should be available on `https://localhost/pem`. Sometimes it takes a few minutes for the PEM container to fully stabelize. You can see that happening in your Docker Desktop Dashboard where the CPU of the container is still spiking. Wait for the CPU to stabelize before to continue.

PEM user is `enterprisedb` and the access password for this user can be revealed using `tpaexec show-password pemdemovagrant enterprisedb`. I suggest you copy this password on your clipboard because you will need it in various places.

*Important:* After setting up the demo you need to disconnect from PG1 and PG2, add the EFM parameters to Propeties / Advanced. 
```
EFM cluster name : pemdemovagrant
EFM installation path : /usr/edb/efm-4.7/bin/
```
This enables you to use the streaming replication dashboard.

Another enhancement would be to set up a cron job which runs pgbench like this:
```
0,30 * * * * (PGPASSWORD='&I$iHuprYGOljC1CKoljC7H%7$HTmLLl' pgbench -h 192.168.0.211 -p 5444 -T 100 -c 10 -j 2 -U enterprisedb postgres) 2>&1 |logger -t pgbench
```
Pgbench is already initialized into the `postgres` database by the provisioning script.

## Demo flow
### Overview PEM dashboards
Open a broweser, go to http://localhost/pem and log in using user `enterprisedb` and the password you got at the end of the provisioning process.

Give an overview of the UI and the dashboards.
- Select Monitoring
- Select Global Overview / pg1 / Alerts. You see one alert. Deep-dive into that alert.
- Select pg1 / Alerts. Click on the alert (Swap consumption percentage) and explain settings. Explain notification methods.
- Acknowledge the alert.
- Select Home / Alerts to show all alerts.

#### Alerts overview
- Right-click on pg1 and select Management / Manage Probes
- Show some system probes (eg. Database Statistics)
- Show table `pemdata.table_statistics` which contains the same data.
- Right-click on pg1 and select Management / Manage Alerts. 
- Select Alert Templates, Database size and press th pencil.
- Show Probe dependency and the tabe used in the SQL tab.
- Show Alert Templates, Email Templates.

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

### Performance diagnostics
- Select pg1 and from the top meno, select the overall dashboard.
- Open a teminal and get the password for user `dba` using `taexec show-password pemdemovagrant dba`.
- In the same terminal, generate traffic using `pgbench -h localhost -p 5444 -i -U dba postgres` and then `pgbench -h localhost -p 5444 -T 100 -c 10 -j 2 -U dba postgres`. 
- Select Tools / Server / Performance diagostics and walk through the Wait events dertails options.

Show barman graphs
- Select the Barman server and select the dashboard.

### Data dictionary
Open database `pem` on the pemserver and show three schemas for PEM configuration (`pem`), PEM data (`pemdata`) and PEM hostorical data (`pemhstory`).
- Right-click on pem/Tables/agent and select Edit/View data / All rows.
- Right-click on `agent` and select Query Tool and show that you can query the agent table using `select * from pem.agent`.
- Do the same for `agent_config`
- Do the same for several tables in the `pemdata` schema. Specifically show `cpu_usage`
- Show `cpu-usage` in `pemhistory` and explain the difference between `pemdata` and `pemhistory`.

## Demo cleanup
To clean up the demo environment you just have to run `99-deprovision.sh`. This script will remove the docker containers and the cluster configuration.

## Closing remarks
This demo is broken on Docker Engine V25 and beyond (eg. Docker Desktop for Mac v4.27 and later). You will get the following error:
```
TASK [sys : Enable rc-local service] *********************************************************************************************************************************************************************************************************
fatal: [pg1]: FAILED! => {"changed": false, "cmd": "/usr/bin/systemctl", "msg": "Failed to connect to bus: No such file or directory", "rc": 1, "stderr": "Failed to connect to bus: No such file or directory\n", "stderr_lines": ["Failed to connect to bus: No such file or directory"], "stdout": "", "stdout_lines": []}
```
This is a Docker Engine issue and the only way i found to work around this is to run a pre-V25 Docker Engine. For Docker Desktop for Mac this is version 4.26.1.

## Fixes TODO
![alt text](image.png)

Streaming setup

OS dashboards not working

## Enhancements

REST API demo flow



