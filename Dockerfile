FROM debian:buster-slim
MAINTAINER Zedix

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_US.UTF-8
ENV LANGUAGE en_US:en

RUN \
 apt-get update &&\
 apt-get -y --no-install-recommends install curl locales apt-utils &&\
 echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen &&\
 locale-gen en_US.UTF-8 &&\
 /usr/sbin/update-locale LANG=en_US.UTF-8 &&\
 echo "mysql-server mysql-server/root_password password root" | debconf-set-selections &&\
 echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections &&\
 apt-get -y --no-install-recommends install ca-certificates gnupg git subversion imagemagick openssh-client curl software-properties-common gettext zip unzip default-mysql-server default-mysql-client apt-transport-https ruby python python3 perl memcached geoip-database make ffmpeg &&\
 curl -sSL https://deb.nodesource.com/setup_10.x | bash -

# Add Sury PHP repository
RUN wget -O sury.gpg https://packages.sury.org/php/apt.gpg && apt-key add sury.gpg && rm sury.gpg
COPY files/sury.list /etc/apt/sources.list.d/sury.list

# Install PHP with some extensions
RUN apt-get update && \
    apt-get --no-install-recommends --no-install-suggests --yes --quiet install \
        php7.4-cli php7.4-apcu php7.4-fpm php7.4-dom php7.4-mbstring php7.4-curl \
        php7.4-gd php7.4-imagick php7.4-intl php7.4-bcmath \
        php7.4-mysql php7.4-xdebug php7.4-xml php7.4-zip && \
    apt-get clean && apt-get --yes --quiet autoremove --purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* /var/log/*

RUN \
 sed -ri -e "s/^variables_order.*/variables_order=\"EGPCS\"/g" /etc/php/7.4/cli/php.ini &&\
 echo "\nmemory_limit=-1" >> /etc/php/7.4/cli/php.ini &&\
 echo "xdebug.max_nesting_level=250" >> /etc/php/7.4/mods-available/xdebug.ini

RUN \
 curl -sSL https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/bin &&\
 curl -sSL https://phar.phpunit.de/phpunit.phar -o /usr/bin/phpunit  && chmod +x /usr/bin/phpunit &&\
 curl -sSL https://codeception.com/codecept.phar -o /usr/bin/codecept && chmod +x /usr/bin/codecept &&\
 curl -sSL https://github.com/infection/infection/releases/download/0.12.0/infection.phar -o /usr/bin/infection && chmod +x /usr/bin/infection &&\
 npm install --no-color --production --global gulp-cli webpack mocha grunt yarn n &&\
 rm -rf /root/.npm /tmp/* /var/tmp/* /var/lib/apt/lists/* /var/log/*
