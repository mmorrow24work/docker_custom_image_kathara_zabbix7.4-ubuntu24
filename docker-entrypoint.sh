#!/bin/bash
set -e

# Start MySQL
service mariadb start

# Wait for MySQL to be ready
until mysql -uroot -e "SELECT 1;" &> /dev/null; do
    sleep 1
done

# Create Zabbix DB and user access for specific hosts
mysql -uroot <<-EOSQL
  -- Remove anonymous users (optional in test setups)
  DELETE FROM mysql.user WHERE User='';

  -- Create database if not exists
  CREATE DATABASE IF NOT EXISTS \`${ZABBIX_DBNAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

  -- Grant access from localhost (socket or 127.0.0.1)
  CREATE USER IF NOT EXISTS '${ZABBIX_DBUSER}'@'localhost' IDENTIFIED BY '${ZABBIX_DBPASSWORD}';
  GRANT ALL PRIVILEGES ON \`${ZABBIX_DBNAME}\`.* TO '${ZABBIX_DBUSER}'@'localhost';

  -- Grant access from 172.17.0.2
  CREATE USER IF NOT EXISTS '${ZABBIX_DBUSER}'@'172.17.0.2' IDENTIFIED BY '${ZABBIX_DBPASSWORD}';
  GRANT ALL PRIVILEGES ON \`${ZABBIX_DBNAME}\`.* TO '${ZABBIX_DBUSER}'@'172.17.0.2';

  -- Grant access from 172.17.0.1
  CREATE USER IF NOT EXISTS '${ZABBIX_DBUSER}'@'172.17.0.1' IDENTIFIED BY '${ZABBIX_DBPASSWORD}';
  GRANT ALL PRIVILEGES ON \`${ZABBIX_DBNAME}\`.* TO '${ZABBIX_DBUSER}'@'172.17.0.1';

  -- Apply permissions
  FLUSH PRIVILEGES;
EOSQL


# Enable log_bin_trust_function_creators option after importing database schema.
mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "SET GLOBAL log_bin_trust_function_creators = 1;"

# Import initial schema if tables are missing
if ! mysql -u${ZABBIX_DBUSER} -p${ZABBIX_DBPASSWORD} ${ZABBIX_DBNAME} -e "show tables;" | grep -q users; then
    zcat /usr/share/zabbix/sql-scripts/mysql/server.sql.gz | mysql -u${ZABBIX_DBUSER} -p${ZABBIX_DBPASSWORD} ${ZABBIX_DBNAME}
fi

# Disable log_bin_trust_function_creators option after importing database schema.
mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "SET GLOBAL log_bin_trust_function_creators = 0;"

# Configure Zabbix server DB access
#  sed -i "s/^DBPassword=.*/DBPassword=${ZABBIX_DBPASSWORD}/" /etc/zabbix/zabbix_server.conf
sed -i "s/^# *DBPassword=.*/DBPassword=${ZABBIX_DBPASSWORD}/" /etc/zabbix/zabbix_server.conf

# Configure Zabbix server EnableGlobalScripts=1 ( default EnableGlobalScripts=0 ) 
sed -i -E 's|^#?\s*EnableGlobalScripts\s*=.*|EnableGlobalScripts=1|' /etc/zabbix/zabbix_server.conf

# Configure Zabbix server StartPingers=5 ( default #StartPingers=1 ) 
sed -i -E 's|^#?\s*StartPingers\s*=.*|StartPingers=5|' /etc/zabbix/zabbix_server.conf

# Copy fping over cos it was missing from zabbix 7.4 server Ubuntu
# sed -i '/^/usr/sbin/fping\/usr/bin/fping' /etc/zabbix/zabbix_server.conf
sed -i -E 's|^#?\s*FpingLocation=/usr/sbin/fping|FpingLocation=/usr/bin/fping|' /etc/zabbix/zabbix_server.conf
# cp /usr/bin/fping /usr/sbin/fping

# Set up services: Apache, Zabbix server, agent (foreground)
service zabbix-server start
service zabbix-agent start
service apache2 start

# Tail logs to keep the container alive
tail -F /var/log/zabbix/zabbix_server.log

