#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#------------------------- Disable selinux
if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    setenforce 0
fi
#------------------------- Install package
apt -y update
apt -y install nginx mysql-server 
apt -y install php-fpm php-mysql php-common php-gd php-zip php-mbstring php-xml 
apt -y install libmysqlclient-dev libmysql++-dev git make gcc g++ fp-compiler openjdk-11-jdk
#------------------------- Clone source code
/usr/sbin/useradd -m -u 1536 judge
cd /home/judge/
git clone https://github.com/VietThienTran/onlinejudge
#------------------------- Config Server
DBNAME="onlinejudge"
DBUSER="root"
DBPASS="123456"
PHP_VERSION=7.`php -v>&1|awk '{print $2}'|awk -F '.' '{print $2}'`
cat>/etc/nginx/conf.d/onlinejudge.conf<<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /home/judge/onlinejudge/web;
    index index.php;
    server_name _;
    client_max_body_size    128M;
    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php${PHP_VERSION}-fpm.sock;
    }
}
EOF
rm /etc/nginx/sites-enabled/default
DBUSER=`cat /etc/mysql/debian.cnf |grep user|head -1|awk  '{print $3}'`
DBPASS=`cat /etc/mysql/debian.cnf |grep password|head -1|awk  '{print $3}'`
sed -i "s/post_max_size = 8M/post_max_size = 128M/g" /etc/php/${PHP_VERSION}/fpm/php.ini
sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 128M/g" /etc/php/${PHP_VERSION}/fpm/php.ini
systemctl restart nginx
systemctl restart php${PHP_VERSION}-fpm
#------------------------- Create database
mysql -h localhost -u$DBUSER -p$DBPASS -e "create database onlinejudge;"
sed -i "s/root/$DBUSER/g" /home/judge/onlinejudge/config/db.php
sed -i "s/123456/$DBPASS/g" /home/judge/onlinejudge/config/db.php
sed -i "s/host=mysql/host=localhost/g" /home/judge/onlinejudge/config/db.php
sed -i "s/root/$DBUSER/g" /home/judge/onlinejudge/judge/config.ini
sed -i "s/123456/$DBPASS/g" /home/judge/onlinejudge/judge/config.ini
sed -i "s/OJ_HOST_NAME=mysql/OJ_HOST_NAME=localhost/g" /home/judge/onlinejudge/judge/config.ini
sed -i "s/root/$DBUSER/g" /home/judge/onlinejudge/polygon/config.ini
sed -i "s/123456/$DBPASS/g" /home/judge/onlinejudge/polygon/config.ini
sed -i "s/OJ_HOST_NAME=mysql/OJ_HOST_NAME=localhost/g" /home/judge/onlinejudge/polygon/config.ini
#------------------------- Enable Server
systemctl start nginx
systemctl enable nginx
systemctl enable php${PHP_VERSION}-fpm
systemctl enable mysql
#------------------------- Compile Judge and Polygon
cd /home/judge/onlinejudge
echo -e "yes" "\n" "admin" "\n" "123456" "\n" "vietthienbqn1998@gmail.com" | ./yii install
cd /home/judge/onlinejudge/judge
make
./dispatcher
cd /home/judge/onlinejudge/polygon
make
./polygon
#------------------------- Finish
echo
echo "Successful installation"
echo "App running at:"
echo "http://your_ip_address"
echo
echo -e "Administrator account: admin"
echo -e "Password: 123456"
echo
echo "Enjoy it!"
echo
