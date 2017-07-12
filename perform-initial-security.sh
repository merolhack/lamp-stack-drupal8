#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

# @file:		~/scripts/perform-initial-security.sh
# @author		Lenin Meza - InterWare | lmeza@interware.com.mx
# @version		0.0.1

# set -o errexit  	# Exit on error
set -o pipefail
set -o nounset  	# Trigger error when expanding unset variables
# set -o xtrace

## Instrucciones:
## sed 's/\r//' ~/scripts/perform-initial-security.sh > ~/scripts/perform-initial-security.tmp && mv ~/scripts/perform-initial-security.tmp ~/scripts/perform-initial-security.sh
## chmod +x ~/scripts/perform-initial-security.sh
## ~/scripts/perform-initial-security.sh

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)"

echo -e '\E[37;44m'"\033[1m===[ Agregar al usuario actual al grupo de Apache ]===\033[0m"
sudo usermod -a -G apache $USER

echo -e '\E[37;44m'"\033[1m===[ Deshabilitar login de root remotamente ]===\033[0m"
sudo sed -i -e 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
sudo systemctl start sshd.service

echo -e '\E[37;44m'"\033[1m===[ Configuración de SELinux ]===\033[0m"
sudo setsebool -P httpd_can_sendmail on
sudo setsebool -P httpd_can_network_connect on
sudo setsebool -P httpd_can_network_connect_db on

echo -e '\E[37;44m'"\033[1m===[ Instalar FirewallD ]===\033[0m"
sudo yum install firewalld -y
sudo systemctl start firewalld.service
echo -e '\E[37;44m'"\033[1m===[ Agregar servicio http a firewalld ]===\033[0m"
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --reload

echo -e '\E[37;44m'"\033[1m===[ Instalar Mod Security ]===\033[0m"
sudo yum install httpd24u-mod_security2 -y
sudo systemctl restart httpd
sudo chmod 644 /var/log/httpd/modsec_debug.log

echo -e '\E[37;44m'"\033[1m===[ Comprobar versiones instaladas ]===\033[0m"
echo "- FirewallD:"
sudo firewall-cmd -V
echo "- Mod Security:"
rpm -qa | grep "mod_security2"

echo -e '\E[37;44m'"\033[1m *** Debe cerrar y volver a iniciar sesión *** \033[0m"

source ~/scripts/set-drupal-permissions.sh

skill -KILL -u $USER