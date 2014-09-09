#!/usr/bin/env bash

# Update Package List

sudo apt-get update

#sudo apt-get upgrade -y

# Install Some PPAs

sudo apt-get install -y software-properties-common

apt-add-repository ppa:nginx/stable -y
apt-add-repository ppa:rwky/redis -y
apt-add-repository ppa:chris-lea/node.js -y
#apt-add-repository ppa:ondrej/php5-5.6 -y

# Update Package Lists

sudo apt-get update

# Install Some Basic Packages

sudo apt-get install -y build-essential curl dos2unix gcc git libmcrypt4 libpcre3-dev \
make python2.7-dev python-pip re2c supervisor unattended-upgrades whois vim

# Install A Few Helpful Python Packages

pip install httpie
pip install fabric
pip install python-simple-hipchat

# Set My Timezone

ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Install PHP Stuffs

sudo apt-get install -y php5 \
php5-mysqlnd php5-pgsql php5-sqlite \
php5-curl php5-gd \
php5-mcrypt php5-xdebug \
php5-memcached

# Make MCrypt Available

ln -s /etc/php5/conf.d/mcrypt.ini /etc/php5/mods-available
#sudo php5enmod mcrypt

# Install Mailparse PECL Extension

# pecl install mailparse
# echo "extension=mailparse.so" > /etc/php5/mods-available/mailparse.ini
# ln -s /etc/php5/mods-available/mailparse.ini /etc/php5/cli/conf.d/20-mailparse.ini

# Install Composer

curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Add Composer Global Bin To Path

printf "\nPATH=\"/home/vagrant/.composer/vendor/bin:\$PATH\"\n" | tee -a /home/vagrant/.profile

# Install Laravel Envoy

sudo su vagrant <<'EOF'
/usr/local/bin/composer global require "laravel/envoy=~1.0"
EOF

# Set Some PHP CLI Settings

sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/cli/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/cli/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php5/cli/php.ini
sudo sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php5/cli/php.ini

# Install Nginx & PHP-FPM

sudo apt-get install -y nginx php5-fpm

rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
sudo service nginx restart

# Setup Some PHP-FPM Options

ln -s /etc/php5/mods-available/mailparse.ini /etc/php5/fpm/conf.d/20-mailparse.ini

sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/fpm/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/fpm/php.ini
sudo sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php5/fpm/php.ini
sudo sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php5/fpm/php.ini

# Set The Nginx & PHP-FPM User

sudo sed -i "s/user www-data;/user vagrant;/" /etc/nginx/nginx.conf

sudo sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf

sudo sed -i "s/user = www-data/user = vagrant/" /etc/php5/fpm/pool.d/www.conf
sudo sed -i "s/group = www-data/group = vagrant/" /etc/php5/fpm/pool.d/www.conf

sed -i "s/^\listen.*$/listen = \/var\/run\/php5-fpm.sock/g" /etc/php5/fpm/pool.d/www.conf
sudo chown vagrant:vagrant /var/run/php5-fpm.sock

sudo sed -i "s/;listen\.owner.*/listen.owner = vagrant/" /etc/php5/fpm/pool.d/www.conf
sudo sed -i "s/;listen\.group.*/listen.group = vagrant/" /etc/php5/fpm/pool.d/www.conf
sudo sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php5/fpm/pool.d/www.conf

sudo service nginx restart
sudo service php5-fpm restart

# Add Vagrant User To WWW-Data

usermod -a -G www-data vagrant
id vagrant
groups vagrant

# Install Node

sudo apt-get install -y nodejs
#npm install -g grunt-cli
#npm install -g gulp
#npm install -g bower

# Install SQLite

sudo apt-get install -y sqlite3 libsqlite3-dev

# Install MySQL

debconf-set-selections <<< "mysql-server mysql-server/root_password password secret"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password secret"
sudo apt-get install -y mysql-server

# Configure MySQL Remote Access

sudo sed -i '/^bind-address/s/bind-address.*=.*/bind-address = 10.0.2.15/' /etc/mysql/my.cnf
mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO root@'10.0.2.2' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
sudo service mysql restart

mysql --user="root" --password="secret" -e "CREATE USER 'homestead'@'10.0.2.2' IDENTIFIED BY 'secret';"
mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO 'homestead'@'10.0.2.2' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO 'homestead'@'%' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
mysql --user="root" --password="secret" -e "FLUSH PRIVILEGES;"
mysql --user="root" --password="secret" -e "CREATE DATABASE homestead;"
sudo service mysql restart

# Install Postgres

sudo apt-get install -y postgresql postgresql-contrib

# Configure Postgres Remote Access

sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/9.1/main/postgresql.conf
echo "host    all             all             10.0.2.2/32               md5" | tee -a /etc/postgresql/9.1/main/pg_hba.conf
sudo -u postgres psql -c "CREATE ROLE homestead LOGIN UNENCRYPTED PASSWORD 'secret' SUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;"
sudo -u postgres /usr/bin/createdb --echo --owner=homestead homestead
sudo service postgresql restart

# Install A Few Other Things

sudo apt-get install -y redis-server memcached beanstalkd

# Configure Beanstalkd

sudo sed -i "s/#START=yes/START=yes/" /etc/default/beanstalkd
sudo /etc/init.d/beanstalkd start

# Write Bash Aliases

#cp /vagrant/aliases /home/vagrant/.bash_aliases
