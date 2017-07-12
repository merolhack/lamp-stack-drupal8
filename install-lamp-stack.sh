#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

# @file:		~/scripts/install-lamp-stack.sh
# @author		Lenin Meza - SociedadRed | merolhack@gmail.com
# @version		0.0.2

# set -o errexit  	# Exit on error
set -o pipefail
set -o nounset  	# Trigger error when expanding unset variables
# set -o xtrace

## Instrucciones:
## sed 's/\r//' ~/scripts/install-lamp-stack.sh > ~/scripts/install-lamp-stack.tmp && mv ~/scripts/install-lamp-stack.tmp ~/scripts/install-lamp-stack.sh
## chmod +x ~/scripts/install-lamp-stack.sh
## ~/scripts/install-lamp-stack.sh

# Tiempo en que inicia la Ejecución
start_date=$(date +"%s")

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)"

# User with sudo
__user="lmeza"

echo "# Instalar Repositorios EPEL e IUS"
sudo yum update -y
sudo yum install zip unzip wget nano telnet -y
curl 'https://setup.ius.io/' -o setup-ius.sh
sudo bash setup-ius.sh
sudo yum update -y
sudo rm -f setup-ius.sh

echo "# Instalar Apache"
sudo yum install httpd24u -y
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl status httpd

echo "# Instalar Varnish"
sudo yum install -y varnish
sudo systemctl start varnish
sudo systemctl enable varnish

echo "# Configurar puertos de Varnish y de Apache"
sudo sed -i -e 's/6081/80/g' /etc/varnish/varnish.params
sudo sed -i -e 's/80/8080/g' /etc/httpd/conf/httpd.conf

echo "# Reiniciar servicos de Apache y Varnish"
sudo systemctl restart httpd
sudo systemctl restart varnish

echo "# Instalar PHP 7.0"
sudo yum install php70u php70u-cli php70u-mbstring php70u-mcrypt php70u-json php70u-opcache php70u-gd php70u-xml -y
sudo yum install php70u-mysqlnd php70u-pdo -y
sudo systemctl restart httpd

echo "# Instalar MariaDB 10.1"
sudo yum install yum-plugin-replace -y
sudo yum replace mariadb-libs --replace-with=mariadb101u-libs -y
sudo yum install mariadb101u mariadb101u-server -y
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo mysql_secure_installation

echo "# Instalar Redis"
sudo yum install redis php70u-pecl-redis -y
sudo systemctl start redis.service
sudo systemctl enable redis.service
sudo systemctl restart httpd

echo "# Instalar composer"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer
sudo chown apache:apache /usr/local/bin/composer
sudo mkdir /usr/share/httpd/.composer
sudo chown -R apache:apache /usr/share/httpd/.composer

echo "# Instalar GIT"
sudo yum install git -y
git config --global user.name "Lenin Meza"
git config --global user.email "merolhack@gmail.com"

echo "# Instalar Drush"
runuser -l $__user -c 'composer global require drush/drush'
sudo chown -h apache:apache /home/$__user/.config/composer/vendor/bin/drush
sudo ln -s /home/$__user/.config/composer/vendor/bin/drush /usr/local/bin/drush
sudo chown -h apache:apache /usr/local/bin/drush
drush core-status

echo "# Comprobar versiones instaladas"
echo "- Varnish:"
varnishd -V
echo "- Apache:"
httpd -v
echo "- PHP:"
php -v
echo "- Redis:"
php -i | grep -i "Redis Support"
redis-server -v
echo "- Composer:"
composer -V
echo "- GIT:"
git --version
echo "- Drush:"
drush version

echo "Instalar HTOP"
sudo yum install htop -y

difftimelps=$(($end_date-$start_date))
echo "$(($difftimelps / 60)) minutos y $(($difftimelps % 60)) segundos han pasado para la ejecución del Script."