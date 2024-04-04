### Overview PEM dashboards
Open a broweser, go to `http://<pemserver IP>/pem` and log in using user `enterprisedb` and the password you got at the end of the provisioning process.

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
