#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

echo "Estado de FirewallD"
sudo firewall-cmd --state

echo "Puertos abiertos en el firewall"
sudo firewall-cmd --list-ports

echo "Estado de la Memoria RAM y la SWAP"
free -m

echo "Espacio disponible en los file systems"
df -h

echo "PING hacia el servidor de redis"
redis-cli ping