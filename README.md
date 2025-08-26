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
  mmorrow24work@digital-twin-version-1-0:~/docker/custom-images/docker_custom_image_kathara_zabbix7.4_frr$ sudo docker build -t zabbix7.4_frr:1.0 .
[+] Building 60.7s (8/8) FINISHED                                                                                                                                                                                                         docker:default
 => [internal] load build definition from Dockerfile                                                                                                                                                                                                0.0s
 => => transferring dockerfile: 1.68kB                                                                                                                                                                                                              0.0s
 => [internal] load metadata for docker.io/kathara/frr:latest                                                                                                                                                                                       1.5s
 => [internal] load .dockerignore                                                                                                                                                                                                                   0.0s
 => => transferring context: 2B                                                                                                                                                                                                                     0.0s
 => [1/4] FROM docker.io/kathara/frr:latest@sha256:8b453c1f69fce93f2f651a0b73c53f7bc3ed9f78e885a9bcd5c785f4abf555e0                                                                                                                                45.0s
 => => resolve docker.io/kathara/frr:latest@sha256:8b453c1f69fce93f2f651a0b73c53f7bc3ed9f78e885a9bcd5c785f4abf555e0                                                                                                                                 0.0s
 => => sha256:fd0410a2d1aece5360035b61b0a60d8d6ce56badb9d30a5c86113b3ec724f72a 48.48MB / 48.48MB                                                                                                                                                    1.3s
 => => sha256:7425ba97a6f14cfd08cecd71f8963637ae1f13484bd8d9b7b96ca84f8a4a1742 15.16MB / 15.16MB                                                                                                                                                    1.3s
 => => sha256:d19966df6a79a48157aa7d928453083e02e688e17d6bd9f2f7df14399ead1eee 207B / 207B                                                                                                                                                          0.7s
 => => sha256:8b453c1f69fce93f2f651a0b73c53f7bc3ed9f78e885a9bcd5c785f4abf555e0 1.61kB / 1.61kB                                                                                                                                                      0.0s
 => => sha256:f1433f17da2ec0ce96e26ad2b288b986ecbd6eff50d3905f47c58e3577477e76 3.52kB / 3.52kB                                                                                                                                                      0.0s
 => => sha256:0fbf3877a39c4c5f42ecc962ff700f301e66a04faaa2f865e7bfc4c2003a0467 8.81kB / 8.81kB                                                                                                                                                      0.0s
 => => sha256:e6134c5a33aad3f1967498a21cd6ffe937cf08a0696ba38bb30fb19a942e7d4f 319.41MB / 319.41MB                                                                                                                                                 10.4s
 => => sha256:cde70b2a4a16498769fdaf05aee1c39034190c16e1be92fd0e301ead1a52afa1 1.24MB / 1.24MB                                                                                                                                                      2.0s
 => => sha256:4f4fb700ef54461cfa02571ae0db9a0dc1e0cdb5577484a6d75e68dc38e8acc1 32B / 32B                                                                                                                                                            1.5s
 => => extracting sha256:fd0410a2d1aece5360035b61b0a60d8d6ce56badb9d30a5c86113b3ec724f72a                                                                                                                                                           5.8s
 => => sha256:6857d1bcc126d053b37a7828c72ecc1a39cc5ce142a8bbb7160e9909f117536a 10.67MB / 10.67MB                                                                                                                                                    2.2s
 => => sha256:5afc2efa84ad86e0335482afacfd19f78e019a5ac6031c6515745ec77620274c 147B / 147B                                                                                                                                                          2.6s
 => => sha256:1391e35c3ca19403d071b6cb10fc5b6c7b4661cdec259755f6080b00a7b0db47 56.25kB / 56.25kB                                                                                                                                                    2.8s
 => => sha256:4737c8663241fa7d81ba2562581e7b01fe3a77c612a1ccd68e18c637402dc576 1.59kB / 1.59kB                                                                                                                                                      3.2s
 => => sha256:8f27f8bae8fd29c3763f454544cca5a22b99778e22ddb37b1950b102231f2683 388B / 388B                                                                                                                                                          3.0s
 => => sha256:e5e275f69c2b1adf53c89b0dee8e718a95de7a88b9b50db57e50cec19fa94e27 12.13kB / 12.13kB                                                                                                                                                    3.8s
 => => sha256:a04e33641901529d92565ba8a3a5b80ba812229923972cb791b931cf73b9dc34 218B / 218B                                                                                                                                                          3.8s
 => => sha256:d2c788a002022205e9dfea4a3f9ddef6203b60ea791709e6c72e7c7edfbd0864 23.54MB / 23.54MB                                                                                                                                                    5.4s
 => => sha256:24c4de2a5e3bc67a220f2f9034f58c65659cf959c12d715dfb7cce7ae55a8435 211B / 211B                                                                                                                                                          4.4s
 => => sha256:bcb89f1e3ed294a7e960b87b6dea1544883542690c0f92538b39abb30c9fe7af 425B / 425B                                                                                                                                                          5.0s
 => => sha256:bd89cb40bc633c5044cbf60dc9a917aea7bb6e810d5186493122f64a8de87f80 614B / 614B                                                                                                                                                          5.6s
 => => extracting sha256:7425ba97a6f14cfd08cecd71f8963637ae1f13484bd8d9b7b96ca84f8a4a1742                                                                                                                                                           0.6s
 => => extracting sha256:d19966df6a79a48157aa7d928453083e02e688e17d6bd9f2f7df14399ead1eee                                                                                                                                                           0.0s
 => => extracting sha256:e6134c5a33aad3f1967498a21cd6ffe937cf08a0696ba38bb30fb19a942e7d4f                                                                                                                                                          30.1s
 => => extracting sha256:4f4fb700ef54461cfa02571ae0db9a0dc1e0cdb5577484a6d75e68dc38e8acc1                                                                                                                                                           0.0s
 => => extracting sha256:cde70b2a4a16498769fdaf05aee1c39034190c16e1be92fd0e301ead1a52afa1                                                                                                                                                           0.1s
 => => extracting sha256:6857d1bcc126d053b37a7828c72ecc1a39cc5ce142a8bbb7160e9909f117536a                                                                                                                                                           1.4s
 => => extracting sha256:5afc2efa84ad86e0335482afacfd19f78e019a5ac6031c6515745ec77620274c                                                                                                                                                           0.0s
 => => extracting sha256:1391e35c3ca19403d071b6cb10fc5b6c7b4661cdec259755f6080b00a7b0db47                                                                                                                                                           0.0s
 => => extracting sha256:4737c8663241fa7d81ba2562581e7b01fe3a77c612a1ccd68e18c637402dc576                                                                                                                                                           0.0s
 => => extracting sha256:8f27f8bae8fd29c3763f454544cca5a22b99778e22ddb37b1950b102231f2683                                                                                                                                                           0.0s
 => => extracting sha256:e5e275f69c2b1adf53c89b0dee8e718a95de7a88b9b50db57e50cec19fa94e27                                                                                                                                                           0.0s
 => => extracting sha256:a04e33641901529d92565ba8a3a5b80ba812229923972cb791b931cf73b9dc34                                                                                                                                                           0.0s
 => => extracting sha256:d2c788a002022205e9dfea4a3f9ddef6203b60ea791709e6c72e7c7edfbd0864                                                                                                                                                           1.0s
 => => extracting sha256:24c4de2a5e3bc67a220f2f9034f58c65659cf959c12d715dfb7cce7ae55a8435                                                                                                                                                           0.0s
 => => extracting sha256:bcb89f1e3ed294a7e960b87b6dea1544883542690c0f92538b39abb30c9fe7af                                                                                                                                                           0.0s
 => => extracting sha256:bd89cb40bc633c5044cbf60dc9a917aea7bb6e810d5186493122f64a8de87f80                                                                                                                                                           0.0s
 => [2/4] RUN apt-get update && apt-get install -y     zabbix-agent     snmpd     snmp     softflowd     iproute2     iputils-ping     bash     iperf3  && apt-get clean && rm -rf /var/lib/apt/lists/*                                            12.7s
 => [3/4] RUN echo -e "com2sec readonly  default         public\ngroup   myv1group v1            readonly\ngroup   myv2cgroup v2c          readonly\nview    all       included      .1\naccess  myv1group ""      any       noauth    exact  all   0.4s 
 => [4/4] RUN sed -i     -e 's/^Server=127.0.0.1/Server=192.168.10.7/'     -e 's/^Hostname=Zabbix server/Hostname=kathara-frr/'     /etc/zabbix/zabbix_agentd.conf                                                                                  0.4s 
 => exporting to image                                                                                                                                                                                                                              0.4s 
 => => exporting layers                                                                                                                                                                                                                             0.4s 
 => => writing image sha256:e7bc768a1303b8025bebf16200e52f922b55e209a46f48ad85ea69c9e466711f                                                                                                                                                        0.0s 
 => => naming to docker.io/library/zabbix7.4_frr:1.0                                                                                                                                                                                                0.0s 

 1 warning found (use docker --debug to expand):
 - JSONArgsRecommended: JSON arguments recommended for CMD to prevent unintended behavior related to OS signals (line 42)
mmorrow24work@digital-twin-version-1-0:~/docker/custom-images/docker_custom_image_kathara_zabbix7.4_frr$ docker images
permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Head "http://%2Fvar%2Frun%2Fdocker.sock/_ping": dial unix /var/run/docker.sock: connect: permission denied
mmorrow24work@digital-twin-version-1-0:~/docker/custom-images/docker_custom_image_kathara_zabbix7.4_frr$ sudo docker images
REPOSITORY      TAG       IMAGE ID       CREATED              SIZE
zabbix7.4_frr   1.0       e7bc768a1303   About a minute ago   1.09GB
mmorrow24work@digital-twin-version-1-0:~/docker/custom-images/docker_custom_image_kathara_zabbix7.4_frr$ 

```
