#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

## Instrucciones:
## sed 's/\r//' ~/scripts/install-drupal-themes.sh > ~/scripts/install-drupal-themes.tmp && mv ~/scripts/install-drupal-themes.tmp ~/scripts/install-drupal-themes.sh
## chmod +x ~/scripts/install-drupal-themes.sh
## ~/scripts/install-drupal-themes.sh

# Tiempo en que inicia la Ejecución
start_date=$(date +"%s")

# Nombres de los sitios
declare -a site_names=("mazatlan" "puerto_morelos" "el_carmen" "uves" "cu_biodiversidad" "cu_clima")

cd /var/www/html

echo -e '\E[37;44m'"\033[1m===[ Instalar el template de Bootstrap ]===\033[0m"
composer require drupal/bootstrap -v
if [ ! -d ./sites/all/themes ]; then
	mkdir -p ./sites/all/themes
fi
cp -r themes/bootstrap/starterkits/less sites/all/themes
mv sites/all/themes/less sites/all/themes/default
cp -r themes/bootstrap/templates/* sites/all/themes/default/templates/
find sites/all/themes/default -type f -exec rename THEMENAME default '{}' \;
mv sites/all/themes/default/default.starterkit.yml sites/all/themes/default/default.info.yml
find sites/all/themes/default -type f -exec sed -i'' -e 's/THEMETITLE/default/g' '{}' \;
find sites/all/themes/default -type f -exec sed -i'' -e 's/THEMENAME/default/g' '{}' \;
wget https://github.com/twbs/bootstrap/archive/v3.3.7.zip -O /tmp/bootstrap.zip
unzip /tmp/bootstrap.zip -d sites/all/themes/default/
rm -rf /tmp/bootstrap.zip
mv sites/all/themes/default/bootstrap-3.3.7 sites/all/themes/default/bootstrap
cp -a sites/all/themes/default/bootstrap/fonts sites/all/themes/default/fonts
drush en default -y
drush config-set system.theme default default -y
drush cr

echo -e '\E[37;44m'"\033[1m===[ Instalar NodeJs y LESS Compiler ]===\033[0m"
sudo yum install nodejs -y
sudo npm install less -g
echo "exec('lessc sites/all/themes/default/less/style.less sites/all/themes/default/css/style.css > /tmp/less-debug 2>&1');" >> sites/default/settings.php
drush cr

echo -e '\E[37;44m'"\033[1m===[ Instalar modulos compatibles con Bootstrap ]===\033[0m"
composer require drupal/responsive_slideshow drupal/ds drupal/bootstrap_layouts -v
drush en responsive_slideshow ds bootstrap_layouts -y
for i in "${site_names[@]}"
do
   drush @$i en responsive_slideshow ds bootstrap_layouts -y
done

composer require drupal/responsive_menu -v
drush en responsive_menu -y
for i in "${site_names[@]}"
do
	drush @$i en responsive_menu -y
done

mkdir libraries
cd libraries
wget https://github.com/FrDH/jQuery.mmenu/archive/master.zip
unzip master.zip
mv jQuery.mmenu-master mmenu
rm -f master.zip

mkdir hammerjs
wget http://hammerjs.github.io/dist/hammer.min.js -O hammerjs/hammer.min.js

echo "Establecer permisos:"
~/scripts/set-drupal-permissions.sh

end_date=$(date +"%s")
difftimelps=$(($end_date-$start_date))
echo "$(($difftimelps / 60)) minutos y $(($difftimelps % 60)) segundos han pasado para la ejecución del Script."
