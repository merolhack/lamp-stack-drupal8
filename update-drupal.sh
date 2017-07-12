#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

## Instrucciones:
## sed 's/\r//' ~/scripts/update-drupal.sh > ~/scripts/update-drupal.tmp && mv ~/scripts/update-drupal.tmp ~/scripts/update-drupal.sh
## chmod +x ~/scripts/update-drupal.sh
## ~/scripts/update-drupal.sh

# Tiempo en que inicia la Ejecución
start_date=$(date +"%s")

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

_current_date="$(date +%Y%m%d_%H%M%S)"

cd /var/www/html

if [ ! -d ./logs ]; then
	mkdir ./logs
	sudo chown apache:apache ./logs
fi

echo "Actualizar composer globalmente:"
composer global update -vvv 2>> ./logs/$_current_date-update-drupal.log

echo "Actualizar composer localmente:"
composer update -vvv 2>> ./logs/$_current_date-update-drupal.log

echo "Actualizar Drupal:"
drush pm-update -v -y 2>> ./logs/$_current_date-update-drupal.log

echo "Reconstruir cache:"
drush cache-rebuild -v 2>> ./logs/$_current_date-update-drupal.log

echo "Establecer permisos:"
~/scripts/set-drupal-permissions.sh

end_date=$(date +"%s")
difftimelps=$(($end_date-$start_date))
echo "$(($difftimelps / 60)) minutos y $(($difftimelps % 60)) segundos han pasado para la ejecución del Script."
