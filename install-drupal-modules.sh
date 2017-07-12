#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

# @file:		~/scripts/install-drupal-modules.sh
# @author		Lenin Meza - SociedadRed | merolhack@gmail.com
# @version		0.0.1

# set -o errexit  	# Exit on error
set -o pipefail		# 
set -o nounset  	# Trigger error when expanding unset variables
# set -o xtrace		# 

## Instrucciones:
## sed 's/\r//' ~/scripts/install-drupal-modules.sh > ~/scripts/install-drupal-modules.tmp && mv ~/scripts/install-drupal-modules.tmp ~/scripts/install-drupal-modules.sh
## chmod +x ~/scripts/install-drupal-modules.sh
## ~/scripts/install-drupal-modules.sh

# Tiempo en que inicia la Ejecución
start_date=$(date +"%s")
# Nombres de los sitios
declare -a site_names=("mazatlan" "puerto_morelos" "el_carmen" "uves" "cu_biodiversidad" "cu_clima")

source ~/scripts/set-drupal-permissions.sh

cd /var/www/html

composer config repositories.drupal composer https://packages.drupal.org/8

echo -e '\E[37;44m'"\033[1m===[ Habilitar módulos del Core ]===\033[0m"
drush en hal basic_auth rest serialization -y
drush en telephone -y
drush en content_translation config_translation -y
drush en syslog statistics -y
drush en responsive_image -y
drush en tracker -y

for i in "${site_names[@]}"
do
	drush @$i en hal basic_auth rest serialization -y
	drush @$i en telephone -y
	drush @$i en content_translation config_translation -y
	drush @$i en syslog statistics -y
	drush @$i en responsive_image -y
	drush @$i en tracker -y
done

echo -e '\E[37;44m'"\033[1m===[ Instalar: Módulos de Administración ]===\033[0m"
echo -e '\E[37;44m'"\033[1m - Admin Toolbar\033[0m"
echo -e '\E[37;44m'"\033[1m - Google Analytics\033[0m"
echo -e '\E[37;44m'"\033[1m - Backup & Migrate\033[0m"
composer require drupal/admin_toolbar drupal/admin_toolbar_tools drupal/mailsystem drupal/google_analytics drupal/backup_migrate -v
drush en admin_toolbar admin_toolbar_tools mailsystem google_analytics backup_migrate -y
for i in "${site_names[@]}"
do
	drush @$i en admin_toolbar admin_toolbar_tools mailsystem google_analytics backup_migrate -y
done

echo -e '\E[37;44m'"\033[1m - Swift Mailer ]===\033[0m"
composer require swiftmailer/swiftmailer html2text/html2text drupal/swiftmailer -v
drush en swiftmailer -y
for i in "${site_names[@]}"
do
	drush @$i en swiftmailer -y
done

echo -e '\E[37;44m'"\033[1m===[ Instalar: Search API ]===\033[0m"
composer require drupal/search_api drupal/search_api_solr drupal/search_api_solr_multilingual drupal/search_api_page drupal/search_api_autocomplete -v
drush en search_api search_api_solr search_api_solr_defaults -y
drush pmu search_api_solr_defaults -y
drush en search_api_solr_multilingual search_api_page search_api_autocomplete -y
for i in "${site_names[@]}"
do
	drush @$i en search_api search_api_solr search_api_solr_defaults -y
	drush @$i pmu search_api_solr_defaults -y
	drush @$i en search_api_solr_multilingual search_api_page search_api_autocomplete -y
done

echo -e '\E[37;44m'"\033[1m===[ Instalar: REST UI ]===\033[0m"
composer require drupal/restui
drush en restui -y
for i in "${site_names[@]}"
do
	drush @$i en restui -y
done

echo -e '\E[37;44m'"\033[1m===[ Instalar: Minificador de archivos CSS y JS ]===\033[0m"
composer require drupal/advagg -v
drush en advagg -y
for i in "${site_names[@]}"
do
	drush @$i en advagg -y
done

echo -e '\E[37;44m'"\033[1m===[ Instalar: SEO ]===\033[0m"
composer require drupal/metatag drupal/simple_sitemap drupal/yoast_seo -v
drush en metatag simple_sitemap yoast_seo -y
for i in "${site_names[@]}"
do
	drush @$i en metatag simple_sitemap yoast_seo -y
done

echo -e '\E[37;44m'"\033[1m===[ Instalar: Soporte para Redis ]===\033[0m"
composer require drupal/redis -v
drush en redis -y
for i in "${site_names[@]}"
do
	drush @$i en redis -y
done

echo -e '\E[37;44m'"\033[1m===[ Instalar: Administración del Contenido ]===\033[0m"
echo -e '\E[37;44m'"\033[1m - Simple GMaps\033[0m"
composer require drupal/pathauto drupal/fast404 drupal/imce drupal/calendar drupal/menu_link_attributes drupal/simple_gmap -v
drush en pathauto fast404 imce calendar menu_link_attributes simple_gmap -y
for i in "${site_names[@]}"
do
	drush @$i en pathauto fast404 imce calendar menu_link_attributes simple_gmap -y
done

echo -e '\E[37;44m'"\033[1m===[ Instalar: Soporte para video ]===\033[0m"
composer require drupal/video drupal/jw_player -v
drush en video jw_player -y
for i in "${site_names[@]}"
do
	drush @$i en video jw_player -y
done

mkdir -p sites/all/libraries/jwplayer
wget https://ssl.p.jwpcdn.com/player/download/jwplayer-7.8.6.zip -O sites/all/libraries/jwplayer/jwplayer.zip
unzip -j sites/all/libraries/jwplayer/jwplayer.zip -d sites/all/libraries/jwplayer
rm -f sites/all/libraries/jwplayer/jwplayer.zip

drush cache-rebuild

end_date=$(date +"%s")
difftimelps=$(($end_date-$start_date))
echo "$(($difftimelps / 60)) minutos y $(($difftimelps % 60)) segundos han pasado para la ejecución del Script."
