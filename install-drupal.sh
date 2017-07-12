#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

# set -o errexit  	# Exit on error
set -o pipefail
set -o nounset  	# Trigger error when expanding unset variables
# set -o xtrace

## Instrucciones:
## sed 's/\r//' ~/scripts/install-drupal.sh > ~/scripts/install-drupal.tmp && mv ~/scripts/install-drupal.tmp ~/scripts/install-drupal.sh
## chmod +x ~/scripts/install-drupal.sh
## ~/scripts/install-drupal.sh

# Tiempo en que inicia la Ejecución
start_date=$(date +"%s")

# Informacion de la base de datos
_DB_HOST=localhost
_DB_USER=root
_DB_PASS=S3CR3T

echo -e '\E[37;44m'"\033[1m===[ Crea la base de datos y el usuario para el sitio principal ]===\033[0m"
mysql -h $_DB_HOST -u $_DB_USER -p$_DB_PASS << EOF
CREATE DATABASE icmyl_drupal_default
DEFAULT CHARACTER SET utf8 
DEFAULT COLLATE utf8_general_ci;
-- IPv4: Crear usuario
CREATE USER 'icmyl_userd8'@'localhost' IDENTIFIED BY 'S3CR3T';
-- Otorgar privilegios al usuario sobre esa base de datos
GRANT ALL PRIVILEGES ON icmyl_drupal_default.* TO 'icmyl_userd8'@'localhost';
-- Refrescar privilegios
FLUSH PRIVILEGES;
-- IPv4: Crear usuario
CREATE USER 'icmyl_userd8'@'::1' IDENTIFIED BY 'S3CR3T';
GRANT ALL PRIVILEGES ON icmyl_drupal_default.* TO 'icmyl_userd8'@'::1';
-- Refrescar privilegios
FLUSH PRIVILEGES;
EOF

echo -e '\E[37;44m'"\033[1m===[ Descargar Drupal en el Webroot de Apache ]===\033[0m"
sudo rm -rf /var/www/html/*
sudo rm -rf /var/www/html/.*
cd /var/www/
sudo chcon -Rt httpd_sys_rw_content_t /var/www/html
sudo chmod 777 /var/www/html
drush pm-download drupal --drupal-project-rename=html/ --yes

echo -e '\E[37;44m'"\033[1m===[ Cambiar dueño y permisos para directorios y archivos de forma recursiva ]===\033[0m"
sudo chown -R apache:apache /var/www/html
sudo find /var/www/html -type f -exec chmod 0644 {} \;
sudo find /var/www/html -type d -exec chmod 0755 {} \;
sudo chmod 777 /var/www/html/sites/default
sudo chcon -Rt httpd_sys_rw_content_t /var/www/html/sites/default

echo -e '\E[37;44m'"\033[1m===[ Iniciar instalación de Drupal con lenguaje Español ]===\033[0m"
cd /var/www/html
drush site-install standard \
        --db-url='mysql://icmyl_userd8:S3CR3T@localhost:3306/icmyl_drupal_default' \
        --account-name=admin --account-pass=S3CR3T \
        --site-name=ICMYL \
        --site-mail=merolhack@gmail.com \
        --locale=es \
		--yes

if [ ! -d ./logs ]; then
	mkdir ./logs
	sudo chown apache:apache ./logs
fi
cp example.gitignore .gitignore
echo "logs" >> .gitignore
	
echo -e '\E[37;44m'"\033[1m===[ Permitir a Apache escribir sobre el directorio files y modules ]===\033[0m"
cd /var/www/html
sudo chmod 0770 ./sites/default
if [ ! -d ./sites/default/files ]; then
	sudo mkdir ./sites/default/files
fi
sudo chmod -R 0750 ./sites/default/files
sudo chcon -Rt httpd_sys_rw_content_t ./sites/default/files
sudo chcon -Rt httpd_sys_rw_content_t ./modules

echo -e '\E[37;44m'"\033[1m===[ Limpiar cache ]===\033[0m"
drush cache-rebuild

echo -e '\E[37;44m'"\033[1m===[ Crear el directorio privado y agregar la ruta hacia el directorio en la configuración ]===\033[0m"
if [ ! -d ./private/default ]; then
	sudo mkdir -p ./private/default
fi
sudo chown -R apache:apache ./sites/default
sudo touch ./private/default/.htaccess
sudo chmod 764 sites/default/settings.php
echo "\$settings['file_private_path']  = 'private/default';" >> sites/default/settings.php

source ~/scripts/set-drupal-permissions.sh
