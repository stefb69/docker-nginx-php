FROM phusion/baseimage:latest

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

ENV HOME /root

RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

CMD ["/sbin/my_init"]

# Nginx-PHP Installation
RUN apt-get update \
  && DEBIAN_FRONTEND="noninteractive" apt-get install -y emacs24-nox curl wget build-essential python-software-properties \
  && add-apt-repository -y ppa:ondrej/php \
  && add-apt-repository -y ppa:nginx/stable \
  && add-apt-repository -y ppa:chris-lea/node.js \
  && add-apt-repository -y ppa:ecometrica/servers \
  && apt-get update \
  && DEBIAN_FRONTEND="noninteractive" apt-get install -y --force-yes php7.0-cli php7.0-fpm php-apcu php-apcu-bc php7.0-mysql \
     php7.0-curl php7.0-gd php7.0-mcrypt php7.0-intl php7.0-opcache nodejs wkhtmltopdf \
  && sed -i -e "s/;date.timezone =.*/date.timezone = Europe\/Paris/" /etc/php/7.0/fpm/php.ini \
  && sed -i -e "s/output_buffering = 4096/output_buffering = off/" /etc/php/7.0/fpm/php.ini \
  && sed -i -e "s/upload_max_filesize = 2M/upload_max_filesize = 100M/" /etc/php/7.0/fpm/php.ini \
  && sed -i -e "s/;opcache.enable=0/opcache.enable=1/" /etc/php/7.0/fpm/php.ini \
  && sed -i -e "s/;date.timezone =.*/date.timezone = Europe\/Paris/" /etc/php/7.0/cli/php.ini \
  && DEBIAN_FRONTEND="noninteractive" apt-get install -y nginx \
  && echo "daemon off;" >> /etc/nginx/nginx.conf \
  && sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf \
  && sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini \
  && mkdir -p        /var/www \
  && mkdir           /etc/service/nginx
ADD build/conf/web.conf  /etc/nginx/sites-available/web.conf
ADD build/conf/fpm7-symphony.conf /etc/nginx/fpm7-symphony.conf
ADD build/conf/myphp.ini /etc/php/7.0/fpm/conf.d/99-myphp.ini
RUN ln -s /etc/nginx/sites-available/web.conf /etc/nginx/sites-enabled/web.conf
ADD build/nginx.sh  /etc/service/nginx/run
RUN chmod +x        /etc/service/nginx/run \
  && mkdir           /etc/service/phpfpm
ADD build/phpfpm.sh /etc/service/phpfpm/run
RUN chmod +x        /etc/service/phpfpm/run

# End Nginx-PHP

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

