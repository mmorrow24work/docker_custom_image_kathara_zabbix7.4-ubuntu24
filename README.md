# dockerfile used to create the custom docker image used with kathara - zabbix7.4-ubuntu24

Mick Morrow  | Solutions Architect
Email: Mick.Morrow@telent.com
Mobile: 07974398922
Web: www.telent.com

I created this dockerfile for the customer docker image I use for my digital twin kathara lab.conf - see extract below :

```bash
WSL-Ubuntu 24.04.1 LTS:$ cat lab.conf
LAB_DESCRIPTION="Network Configuration Scenario – IS#33B"
LAB_VERSION=1.0
LAB_AUTHOR="Mick Morrow _ Solutions Architect"
LAB_EMAIL=Mick.Morrow@telent.com
LAB_WEB=https://telent.com/

snmp_manager[0]="sms"
snmp_manager[bridged]="true"
snmp_manager[image]="zabbix7.4-ubuntu24"
snmp_manager[port]="8080:80/tcp"
snmp_manager[port]="10051:10051/tcp"
snmp_manager[port]="10050:10050/tcp"

netflowcollector[0]="sms"
netflowcollector[image]="alpine_pc"

pc1[0]="sms"
pc1[image]="alpine_pc"

pc2[0]="24"
pc2[image]="alpine_pc"

WSL-Ubuntu 24.04.1 LTS:$
```

***

* Install dependencies
* Add Zabbix repository & install Zabbix server, web, and agent
* MySQL secure config, database, and user creation at build time (not for production)
* Set up environment for startup script
* Expose ports for Zabbix server, agent, and web frontend

# docker-entrypoint.sh used to modify the custom docker image used with kathara - zabbix7.4-ubuntu24

* Start MySQL
* Wait for MySQL to be ready
* Create Zabbix DB and user access for specific hosts
* Enable log_bin_trust_function_creators option after importing database schema.
* Import initial schema if tables are missing
* Configure Zabbix server DB access
* Configure Zabbix server EnableGlobalScripts=1 ( default EnableGlobalScripts=0 ) 
* Configure Zabbix server StartPingers=5 ( default #StartPingers=1 ) 
* Copy fping over cos it was missing from zabbix 7.4 server Ubuntu
* cp /usr/bin/fping /usr/sbin/fping
* Set up services: Apache, Zabbix server, agent (foreground)
* Tail logs to keep the container alive
