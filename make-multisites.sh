#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

# @file:		~/scripts/make-multisites.sh
# @author		Lenin Meza - SociedadRed | merolhack@gmail.com
# @version		0.0.1

# set -o errexit  	# Exit on error
set -o pipefail
set -o nounset  	# Trigger error when expanding unset variables
# set -o xtrace

## Instrucciones:
## sed 's/\r//' ~/scripts/make-multisites.sh > ~/scripts/make-multisites.tmp && mv ~/scripts/make-multisites.tmp ~/scripts/make-multisites.sh
## chmod +x ~/scripts/make-multisites.sh
## ~/scripts/make-multisites.sh

# Tiempo en que inicia la Ejecución
start_date=$(date +"%s")

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)"

# Informacion de la base de datos
_DB_HOST=localhost
_DB_USER=root
_DB_PASS=S3CR3T

# Nombres de los sitios
declare -a site_names=("mazatlan" "puerto_morelos" "el_carmen" "uves" "cu_biodiversidad" "cu_clima")

echo -e '\E[37;44m'"\033[1m===[ Copiar el archivo de ejemplo de la configuración general de los sitios y agregar la configuración de cada sitio ]===\033[0m"
cd /var/www/html/
cp sites/example.sites.php sites/sites.php
for i in "${site_names[@]}"
do
   echo "\$sites['unam.local.$i'] = '$i';" >> sites/sites.php
done

echo -e '\E[37;44m'"\033[1m===[ Crear directorios de los sitios para almacenar archivos ]===\033[0m"
for i in "${site_names[@]}"
do
	if [ ! -d sites/$i/files ]; then
		mkdir -p sites/$i/files
	fi
done

echo -e '\E[37;44m'"\033[1m===[ Copiar archivo de ejemplo de configuración para cada uno de los sitios ]===\033[0m"
for i in "${site_names[@]}"
do
	cp sites/default/default.settings.php sites/$i/settings.php
done

echo -e '\E[37;44m'"\033[1m===[ Crear directorio para almacenar archivos privados así como los respaldos ]===\033[0m"
for i in "${site_names[@]}"
do
	if [ ! -d private/$i/backup_migrate ]; then
		mkdir -p private/$i/backup_migrate
	fi
done

echo -e '\E[37;44m'"\033[1m===[ Crear directorio para almacenar archivos temporales ]===\033[0m"
for i in "${site_names[@]}"
do
	if [ ! -d private/$i/tmp ]; then
		mkdir private/$i/tmp
	fi
done

echo -e '\E[37;44m'"\033[1m===[ Crear enlace simbólico hacia cada uno de los sitios ]===\033[0m"
for i in "${site_names[@]}"
do
	ln -s . $i
	sudo chown -h apache:apache $i
done

echo -e '\E[37;44m'"\033[1m===[ Agregar configuraciones al archivo settings.php ]===\033[0m"
for i in "${site_names[@]}"
do
	cat <<EOT >> sites/$i/settings.php
// Avoiding sites name collision
\$settings['cache_prefix']['default'] = '$i\_';

// Private files directory
\$settings['file_private_path']  = 'private/$i';

// Temporary files directory
\$config['system.file']['path']['temporary'] = 'private/$i/tmp';
EOT
done

for i in "${site_names[@]}"
do
	echo -e '\E[37;44m'"\033[1m===[ Instalar: $i ]===\033[0m"
	echo "- Crea la base de datos y asignar el usuario"
	mysql -h $_DB_HOST -u $_DB_USER -p$_DB_PASS << EOF
CREATE DATABASE icmyl_drupal_$i
DEFAULT CHARACTER SET utf8 
DEFAULT COLLATE utf8_general_ci;
-- Otorgar privilegios al usuario sobre esa base de datos
GRANT ALL PRIVILEGES ON icmyl_drupal_$i.* TO 'icmyl_userd8'@'localhost';
GRANT ALL PRIVILEGES ON icmyl_drupal_$i.* TO 'icmyl_userd8'@'::1';
-- Refrescar privilegios
FLUSH PRIVILEGES;
EOF

	echo "- Iniciar instalación de Drupal con lenguaje Español"
	drush site-install standard \
		--sites-subdir=$i \
        --db-url="mysql://icmyl_userd8:S3CR3T@localhost:3306/icmyl_drupal_$i" \
        --account-name=admin --account-pass=S3CR3T \
        --site-name=ICMYL \
        --site-mail=merolhack@gmail.com \
        --locale=es \
		--yes
done

cp ~/scripts/aliases.drushrc.php ~/.drush/aliases.drushrc.php
drush cache-clear drush
source ~/scripts/set-drupal-permissions.sh

echo -e '\E[37;44m'"\033[1m===[ Reconstruir la cache ]===\033[0m"
drush cache-rebuild

echo -e '\E[37;44m'"\033[1m===[ Estado de los subsitios ]===\033[0m"
for i in "${site_names[@]}"
do
   drush @$i status
done

end_date=$(date +"%s")
difftimelps=$(($end_date-$start_date))
echo "$(($difftimelps / 60)) minutos y $(($difftimelps % 60)) segundos han pasado para la ejecución del Script."