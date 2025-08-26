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

# Example build ...

```
mmorrow24work@digital-twin-version-1-0:~/docker/custom-images/docker_custom_image_kathara_zabbix7.4-ubuntu24$ docker --debug build -t kathara_zabbix7.4-ubuntu24:1.0 . 
[+] Building 137.4s (10/10) FINISHED                                                                                                                                                                                                      docker:default
 => [internal] load build definition from Dockerfile                                                                                                                                                                                                0.0s
 => => transferring dockerfile: 1.55kB                                                                                                                                                                                                              0.0s
 => [internal] load metadata for docker.io/library/ubuntu:24.04                                                                                                                                                                                     1.2s
 => [internal] load .dockerignore                                                                                                                                                                                                                   0.0s
 => => transferring context: 2B                                                                                                                                                                                                                     0.0s
 => [1/5] FROM docker.io/library/ubuntu:24.04@sha256:7c06e91f61fa88c08cc74f7e1b7c69ae24910d745357e0dfe1d2c0322aaf20f9                                                                                                                               4.0s
 => => resolve docker.io/library/ubuntu:24.04@sha256:7c06e91f61fa88c08cc74f7e1b7c69ae24910d745357e0dfe1d2c0322aaf20f9                                                                                                                               0.0s
 => => sha256:7c06e91f61fa88c08cc74f7e1b7c69ae24910d745357e0dfe1d2c0322aaf20f9 6.69kB / 6.69kB                                                                                                                                                      0.0s
 => => sha256:35f3a8badf2f74c1b320a643b343536f5132f245cbefc40ef802b6203a166d04 424B / 424B                                                                                                                                                          0.0s
 => => sha256:e0f16e6366fef4e695b9f8788819849d265cde40eb84300c0147a6e5261d2750 2.29kB / 2.29kB                                                                                                                                                      0.0s
 => => sha256:b71466b94f266b4c2e0881749670e5b88ab7a0fd4ca4a4cdf26cb45e4bde7e4e 29.72MB / 29.72MB                                                                                                                                                    1.1s
 => => extracting sha256:b71466b94f266b4c2e0881749670e5b88ab7a0fd4ca4a4cdf26cb45e4bde7e4e                                                                                                                                                           2.6s
 => [internal] load build context                                                                                                                                                                                                                   0.0s
 => => transferring context: 2.94kB                                                                                                                                                                                                                 0.0s
 => [2/5] RUN apt-get update &&     apt-get install -y wget lsb-release gnupg2     apt-transport-https ca-certificates curl software-properties-common     mariadb-server mariadb-client     iperf3 snmp nano iputils-ping apache2 libapache2-mod  99.3s
 => [3/5] RUN wget https://repo.zabbix.com/zabbix/7.4/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest+ubuntu24.04_all.deb &&     dpkg -i zabbix-release_latest+ubuntu24.04_all.deb &&     apt-get update &&     apt-get install -  21.3s 
 => [4/5] COPY docker-entrypoint.sh /usr/local/bin/                                                                                                                                                                                                 0.1s 
 => [5/5] RUN chmod +x /usr/local/bin/docker-entrypoint.sh                                                                                                                                                                                          0.3s 
 => exporting to image                                                                                                                                                                                                                             10.9s 
 => => exporting layers                                                                                                                                                                                                                            10.9s 
 => => writing image sha256:7a6a227f5cf2a05b0136ee122f1ead4442492ee09745d48a6cb466bbdb318022                                                                                                                                                        0.0s 
 => => naming to docker.io/library/kathara_zabbix7.4-ubuntu24:1.0                                                                                                                                                                                   0.0s 

 1 warning found:
 - SecretsUsedInArgOrEnv: Do not use ARG or ENV instructions for sensitive data (ENV "MYSQL_ROOT_PASSWORD") (line 29)
Sensitive data should not be used in the ARG or ENV commands
More info: https://docs.docker.com/go/dockerfile/rule/secrets-used-in-arg-or-env/
Dockerfile:29
--------------------
  28 |     # Set up environment for startup script
  29 | >>> ENV MYSQL_ROOT_PASSWORD=rootpass \
  30 | >>>     ZABBIX_DBNAME=zabbix \
  31 | >>>     ZABBIX_DBUSER=zabbix \
  32 | >>>     ZABBIX_DBPASSWORD=zabbixpass
  33 |     
--------------------

mmorrow24work@digital-twin-version-1-0:~/docker/custom-images/docker_custom_image_kathara_zabbix7.4-ubuntu24$ docker images
REPOSITORY                   TAG       IMAGE ID       CREATED          SIZE
kathara_zabbix7.4-ubuntu24   1.0       7a6a227f5cf2   15 seconds ago   803MB
zabbix7.4_frr                1.0       e7bc768a1303   40 minutes ago   1.09GB
mmorrow24work@digital-twin-version-1-0:~/docker/custom-images/docker_custom_image_kathara_zabbix7.4-ubuntu24$
```


```
