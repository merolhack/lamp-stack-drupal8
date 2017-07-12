#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

# @file:		~/scripts/set-drupal-permissions.sh
# @author		Lenin Meza - InterWare | lmeza@interware.com.mx
# @version		0.0.1

# set -o errexit  	# Exit on error
set -o pipefail
set -o nounset  	# Trigger error when expanding unset variables
# set -o xtrace

## Instrucciones:
## sed 's/\r//' ~/scripts/set-drupal-permissions.sh > ~/scripts/set-drupal-permissions.tmp && mv ~/scripts/set-drupal-permissions.tmp ~/scripts/set-drupal-permissions.sh
## chmod +x ~/scripts/set-drupal-permissions.sh
## ~/scripts/set-drupal-permissions.sh

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)"

# Nombres de los sitios
declare -a site_names=("mazatlan" "puerto_morelos" "el_carmen" "uves" "cu_biodiversidad" "cu_clima")

# stat -c "%a %n" /var/www/html

cd /var/www/html

echo "0.- Reestablecer el contexto"
sudo restorecon -R /var/www/html
echo "1.- Cambiar propietario del webroot de Apache"
sudo chown -R apache:apache /var/www/html
echo "2.- Cambiar permisos en forma recursiva al webroot de Apache"
sudo chmod -R g+w /var/www/html
echo "3.- Cambiar permisos sólo al webroot de Apache"
sudo chmod g+s /var/www/html
echo "4.- Establecer permisos 755 a todos los directorios"
sudo find /var/www/html -type d -exec chmod 0755 {} \;
echo "5.- Establecer permisos 644 a todos los archivos"
sudo find /var/www/html -type f -exec chmod 0644 {} \;
echo "6.- Establecer permisos 750 a los archivos de los sitios"
sudo chmod -R 0750 /var/www/html/sites/default/files
sudo chmod 444 /var/www/html/sites/default/files/.htaccess
for i in "${site_names[@]}"
do
	if [ -d /var/www/html/sites/$i ]; then
		sudo chmod -R 0750 /var/www/html/sites/$i/files
	fi
done
echo "7.- Establecer permisos de SELinux"
sudo chcon -Rt httpd_sys_content_t /var/www/html
sudo chcon -Rt httpd_sys_rw_content_t /var/www/html/sites/default/files
for i in "${site_names[@]}"
do
	if [ -d /var/www/html/sites/$i ]; then
		sudo chcon -Rt httpd_sys_rw_content_t /var/www/html/sites/$i/files
	fi
done

sudo chcon -Rt httpd_sys_rw_content_t /var/www/html/modules
sudo chcon -Rt httpd_sys_rw_content_t /var/www/html/vendor
sudo chcon -Rt httpd_sys_rw_content_t /var/www/html/private/default
for i in "${site_names[@]}"
do
	if [ -d /var/www/html/private/$i ]; then
		sudo chcon -Rt httpd_sys_rw_content_t /var/www/html/private/$i
	fi
done

echo "8.- Establecer ACL"
sudo setfacl -R -m u:apache:rwx /var/www/html
sudo setfacl -R -m d:u:apache:rwx /var/www/html
sudo setfacl -R -m g:apache:rwx /var/www/html
sudo setfacl -R -m d:g:apache:rwx /var/www/html
