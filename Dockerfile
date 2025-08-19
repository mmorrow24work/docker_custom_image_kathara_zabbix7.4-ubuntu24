FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies

RUN apt-get update && \
    apt-get install -y wget lsb-release gnupg2 \
    apt-transport-https ca-certificates curl software-properties-common \
    mariadb-server mariadb-client \
    iperf3 snmp nano iputils-ping apache2 libapache2-mod-php php php-mysql php-gd php-bcmath php-xml php-mbstring php-ldap php-json php-ctype php-xmlreader php-xmlwriter php-intl php-zip \
    locales tzdata && \
    locale-gen en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

# Add Zabbix repository & install Zabbix server, web, and agent
RUN wget https://repo.zabbix.com/zabbix/7.4/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest+ubuntu24.04_all.deb && \
    dpkg -i zabbix-release_latest+ubuntu24.04_all.deb && \
    apt-get update && \
    apt-get install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent zabbix-get  && \
    rm -f zabbix-release_latest+ubuntu24.04_all.deb && \
    rm -rf /var/lib/apt/lists/*

# MySQL secure config, database, and user creation at build time (not for production)
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set up environment for startup script
ENV MYSQL_ROOT_PASSWORD=rootpass \
    ZABBIX_DBNAME=zabbix \
    ZABBIX_DBUSER=zabbix \
    ZABBIX_DBPASSWORD=zabbixpass

# Expose ports for Zabbix server, agent, and web frontend
EXPOSE 80 10051 10050

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
