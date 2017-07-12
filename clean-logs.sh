#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace


echo "### Apache y Mod Security ###"
echo "- Eliminar logs antiguos"
sudo sh -c 'rm -rf /var/log/httpd/access_log-*'
sudo sh -c 'rm -rf /var/log/httpd/error_log-*'
sudo sh -c 'rm -rf /var/log/httpd/modsec_audit.log-*'
sudo sh -c 'rm -rf /var/log/httpd/modsec_debug.log-*'

echo "- Limpiar logs actuales"
sudo sh -c 'cat /dev/null > /var/log/httpd/access_log'
sudo sh -c 'cat /dev/null > /var/log/httpd/error_log'
sudo sh -c 'cat /dev/null > /var/log/httpd/modsec_audit.log'
sudo sh -c 'cat /dev/null > /var/log/httpd/modsec_debug.log'

echo "### MariaDB ###"
echo "- Limpiar log actual"
sudo sh -c 'cat /dev/null > /var/log/mariadb/mariadb.log'

echo "### Redis ###"
echo "- Eliminar logs antiguos"
sudo sh -c 'rm -rf /var/log/redis/redis.log-*'

echo "- Limpiar log actual"
sudo sh -c 'cat /dev/null > /var/log/redis/redis.log'

echo "### Apache Solr ###"
echo "- Eliminar logs antiguos"
sudo sh -c 'rm -rf /var/solr/logs/solr.log.*'

echo "- Limpiar log actual"
sudo sh -c 'cat /dev/null > /var/solr/logs/solr.log'

echo "### Sistema ###"
echo "- Eliminar logs 'maillog', 'messages', 'secure', 'spooler' y 'cron' antiguos"
sudo sh -c 'rm -rf /var/log/maillog-*'
sudo sh -c 'rm -rf /var/log/messages-*'
sudo sh -c 'rm -rf /var/log/secure-*'
sudo sh -c 'rm -rf /var/log/spooler-*'
sudo sh -c 'rm -rf /var/log/cron-*'

