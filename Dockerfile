FROM debian:jessie
MAINTAINER Gabriele Facciolo <gfacciol@gmail.com>
# Following http://git.27o.de/dataserver/about/Installation-Instructions-for-Debian-Wheezy.md

# debian packages
RUN apt-get update && apt-get install -y \
    apache2 libapache2-mod-php5 memcached zendframework php5-cli php5-memcached php5-mysql php5-curl \
    apache2 uwsgi uwsgi-plugin-psgi libplack-perl libdigest-hmac-perl libjson-xs-perl libfile-util-perl \
    libapache2-mod-uwsgi libswitch-perl mysql-client\
    git gnutls-bin runit wget curl net-tools vim build-essential

# Zotero
RUN mkdir -p /srv/zotero/log/upload && \
    mkdir -p /srv/zotero/log/download && \
    mkdir -p /srv/zotero/log/error && \
    mkdir -p /srv/zotero/log/api-errors && \
    mkdir -p /srv/zotero/log/sync-errors && \
    mkdir -p /srv/zotero/dataserver && \
    mkdir -p /srv/zotero/zss && \
    mkdir -p /var/log/httpd/sync-errors && \
    mkdir -p /var/log/httpd/api-errors && \
    chown www-data: /var/log/httpd/sync-errors && \
    chown www-data: /var/log/httpd/api-errors

# Dataserver
RUN git clone --depth=1 git://git.27o.de/dataserver /srv/zotero/dataserver
RUN chown www-data:www-data /srv/zotero/dataserver/tmp
#RUN cd /srv/zotero/dataserver/include && rm -r Zend && ln -s /usr/share/php/libzend-framework-php/Zend
RUN cd /srv/zotero/dataserver/include && rm -r Zend && ln -s /usr/share/php/Zend

#Apache2
#certtool -p --sec-param high --outfile /etc/apache2/zotero.key
#certtool -s --load-privkey /etc/apache2/zotero.key --outfile /etc/apache2/zotero.cert
ADD apache/zotero.key /etc/apache2/
ADD apache/zotero.cert /etc/apache2/
RUN rm -f /etc/apache2/sites-enabled/*.conf
ADD apache/sites-zotero.conf /etc/apache2/sites-enabled/zotero.conf
ADD apache/dot.htaccess  /srv/zotero/dataserver/htdocs/\.htaccess
RUN a2enmod ssl
RUN a2enmod rewrite


#Mysql
# ADD mysql/zotero.cnf /etc/mysql/conf.d/zotero.cnf
# ADD mysql/setup_db /srv/zotero/dataserver/misc/setup_db
# RUN /etc/init.d/mysql start && \
    # mysqladmin -u root password password && \
    # cd /srv/zotero/dataserver/misc/ && \
    # ./setup_db


# Zotero Configuration
ADD dataserver/dbconnect.inc.php /srv/zotero/dataserver/include/config/
ADD dataserver/config.inc.php /srv/zotero/dataserver/include/config/
ADD dataserver/sv/zotero-download /etc/sv/zotero-download
ADD dataserver/sv/zotero-upload   /etc/sv/zotero-upload  
ADD dataserver/sv/zotero-error    /etc/sv/zotero-error   
RUN cd /etc/service && \
    ln -s ../sv/zotero-download /etc/service/ && \
    ln -s ../sv/zotero-upload /etc/service/ && \
    ln -s ../sv/zotero-error /etc/service/ 

# ZSS
RUN git clone --depth=1 git://git.27o.de/zss /srv/zotero/zss && \
    mkdir /srv/zotero/storage && \
    chown www-data:www-data /srv/zotero/storage

ADD zss/zss.yaml /etc/uwsgi/apps-enabled/zss.yaml
ADD zss/zss.ini /etc/uwsgi/
ADD zss/ZSS.pm   /srv/zotero/zss/
ADD zss/zss.psgi /srv/zotero/zss/
ADD patches/uwsgi /etc/init.d/uwsgi 


# replace custom /srv/zotero/dataserver/admin/add_user that allows to write the password
ADD patches/add_user /srv/zotero/dataserver/admin/add_user

# TEST ADD USER: test PASSWORD: test
# RUN service mysql start && service memcached start && \
#     cd /srv/zotero/dataserver/admin && \
#     ./add_user 101 test test && \
#     ./add_user 102 test2 test2 && \
#     ./add_group -o test -f members -r members -e members testgroup && \
#     ./add_groupuser testgroup test2 member 


# docker server startup
EXPOSE 80 443

RUN mkdir -p /srv/web-library

RUN apt-get install -y supervisor

ADD supervisor/supervisord.conf /etc/supervisor/supervisord.conf
ADD memcached/memcached.conf /etc/memcached.conf

RUN mkdir -p /var/run/uwsgi/app/zss
# CMD service mysql start && \
#     service uwsgi start && \
#     service apache2 start && \
#     service memcached start && \
#     bash -c "/usr/sbin/runsvdir-start &" && \
#     /bin/bash


CMD [ "supervisord", "-c", "/etc/supervisor/supervisord.conf" ]
