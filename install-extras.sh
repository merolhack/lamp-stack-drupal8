#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

# @file:		~/scripts/install-extras.sh
# @author		Lenin Meza - InterWare | lmeza@interware.com.mx
# @version		0.0.1

# set -o errexit  	# Exit on error
set -o pipefail		# 
set -o nounset  	# Trigger error when expanding unset variables
# set -o xtrace		# 

## Instrucciones:
## sed 's/\r//' ~/scripts/install-extras.sh > ~/scripts/install-extras.tmp && mv ~/scripts/install-extras.tmp ~/scripts/install-extras.sh
## chmod +x ~/scripts/install-extras.sh
## ~/scripts/install-extras.sh

# Tiempo en que inicia la Ejecución
start_date=$(date +"%s")

sudo yum install monit -y
sudo systemctl enable monit
sudo systemctl start monit
sudo systemctl status monit
sudo firewall-cmd --permanent --add-port=2812/tcp
sudo firewall-cmd --reload

sudo yum install java-1.8.0-openjdk.x86_64 -y
export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk-1.8.0.121-0.b13.el7_3.x86_64
echo 'export JAVA_HOME="/usr/lib/jvm/jre-1.8.0-openjdk-1.8.0.121-0.b13.el7_3.x86_64"' | sudo tee -a /etc/profile
echo $JAVA_HOME

sudo adduser solr
cd /tmp
wget http://www-us.apache.org/dist/lucene/solr/6.4.0/solr-6.4.0.tgz
tar -zxvf solr-6.4.0.tgz
cd solr-6.4.0
sudo bin/install_solr_service.sh /tmp/solr-6.4.0.tgz
sudo sed -i -e 's/#SOLR_HEAP="512m"/SOLR_HEAP="1024m"/g' /etc/default/solr.in.sh
sudo sed -i -e 's/#SOLR_JAVA_MEM="-Xms512m -Xmx512m"/SOLR_JAVA_MEM="-Xms1024m -Xmx1024m"/g' /etc/default/solr.in.sh
sudo systemctl restart solr

sudo firewall-cmd --zone=public --add-port=8983/tcp --permanent
sudo firewall-cmd --reload

sudo systemctl enable solr
sudo systemctl status solr

cd /tmp
wget https://ftp.drupal.org/files/projects/search_api_solr-8.x-1.0-beta1.tar.gz
tar -zxvf search_api_solr-8.x-1.0-beta1.tar.gz
sudo runuser -l solr -c 'mkdir -p /var/solr/data/default/conf'
sudo cp -R search_api_solr/solr-conf/6.x/* /var/solr/data/default/conf/
sudo chown -R solr:solr /var/solr/data/default

sudo su - solr
cd /opt/solr
./bin/solr create -c default

end_date=$(date +"%s")
difftimelps=$(($end_date-$start_date))
echo "$(($difftimelps / 60)) minutos y $(($difftimelps % 60)) segundos han pasado para la ejecución del Script."