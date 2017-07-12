#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

_current_date="$(date +%Y%m%d_%H%M%S)"

[ -d ~/backups-drupal8 ] || echo "0.- Creando directorio: backups-drupal8." && mkdir -p ~/backups-drupal8

echo "1.- Ingresar al Webroot de Apache"
cd /var/www/html/

echo "2.- Limpiar cache de drupal"
drush cache-rebuild

echo "3.- Generar respaldo de la estructura de la base de datos"
drush sql-dump --extra=--no-data --result-file="~/backups-drupal8/$_current_date-structure.sql"

echo "4.- Generar respaldo de la información de la base de datos"
drush sql-dump --data-only --result-file="~/backups-drupal8/$_current_date-data.sql"

echo "5.- Generar respaldo de los archivos"
tar czf ~/backups-drupal8/$_current_date-files.tar.gz -C /var/www/html/. .
