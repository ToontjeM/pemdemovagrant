## Audit Manager

### Configuration
Select the Audit Manager from the top menu `Management / Audit Manager`. The Audit Manager wizard appears.

Step 1 of 5: Welcome screen.

Step 2 of 5: Select servers which you want to log. 

Step 3 of 5: 
- Enable Auditing. 
- Enable Import logs to PEM.
- Set Import frequency to 5 minutes.
- Change the log directory to `$PGDATA/edb_audit`. This will drop the log files in `/opt/postgres/data/edb_audit`.

Step 4 of 5: 
- Set connection attempts to `Failed`. 
- Set Disconnection attempts to `All`. 
- Set Log statements to 'Error' and 'DML'. 
- Enable log rotation and set to `Everyday`.

Step 5 of 5: Set Configure logging now? to `Yes` and finish the wizard.

Two Scheduled Tasks are now created for the server. You can check if everything is running fine by doing the following:
- Right-click on the server you are auditing.
- Select `Management / Scheduled tasks`. You can see the tasks being run and the log files being created.

### Demo flow
Open a terminal window and navigate to `/opt/postgres/data/edb_audit`. You will see one or more CSV files there with log information.
Use any file viewer to show the contents of the file. Explain that these files can be created in CSV and XML format.

Using PEM, in the PEM Server Directory tree, right-click on your server with Audit enabled and select `Dashboards / Audit log`. Explain the content shown on the screen.
