FROM debian:buster-slim
MAINTAINER Zedix

# Environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_US.UTF-8
ENV LANGUAGE en_US:en

ENV NODE_VERSION 13.x
ENV PHP_VERSION 7.4

# Install tools
RUN apt-get -qq update && \
  apt-get -yqq install \
  apt-utils \
  build-essential \
  curl \
  gettext \
  git-core \
  graphicsmagick \
  libpng-dev \
  locales \
  ntpdate \
  openssh-client \
  pngcrush optipng \
  unzip \
  vim \
  wget \
  && apt-get -q autoclean && rm -rf /var/lib/apt/lists/*

# Install locale
RUN \
 echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
 locale-gen en_US.UTF-8 && \
 /usr/sbin/update-locale LANG=en_US.UTF-8

# Install MySQL server
RUN \
 apt-get update && apt-get -yqq install default-mysql-client default-mysql-server \
 echo "mysql-server mysql-server/root_password password root" | debconf-set-selections && \
 echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections

# Configure Sury PHP repository
RUN apt-get -qq update && \
  apt-get -yqq install apt-transport-https lsb-release ca-certificates && \
  wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
  echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
  apt-get -qq update && apt-get -qqy upgrade && apt-get -q autoclean && rm -rf /var/lib/apt/lists/*

# Install PHP & Extensions
RUN \
 apt-get update &&\
 apt-get --no-install-recommends --no-install-suggests --yes --quiet install \
  php$PHP_VERSION-apcu \
  php$PHP_VERSION-bcmath \
  php$PHP_VERSION-cli \
  php$PHP_VERSION-curl \
  php$PHP_VERSION-dom \
  php$PHP_VERSION-fpm \
  php$PHP_VERSION-gd \
  php$PHP_VERSION-imagick \
  php$PHP_VERSION-intl \
  php$PHP_VERSION-mbstring \
  php$PHP_VERSION-mysql \
  php$PHP_VERSION-xdebug \
  php$PHP_VERSION-xml \
  php$PHP_VERSION-zip \
  && apt-get -q autoclean && rm -rf /var/lib/apt/lists/*

# Configure PHP
RUN \
 sed -ri -e "s/^variables_order.*/variables_order=\"EGPCS\"/g" /etc/php/$PHP_VERSION/cli/php.ini && \
 echo "\nmemory_limit=-1" >> /etc/php/$PHP_VERSION/cli/php.ini && \
 echo "xdebug.max_nesting_level=250" >> /etc/php/$PHP_VERSION/mods-available/xdebug.ini

# Install Composer
RUN curl -sSL https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/bin

# Install PHPUnit
RUN curl -sSL https://phar.phpunit.de/phpunit.phar -o /usr/bin/phpunit && chmod +x /usr/bin/phpunit

# Install Node.js & npm
RUN \
 curl -sSL https://deb.nodesource.com/setup_$NODE_VERSION | bash - && \
 apt-get update && apt-get install -y nodejs

# Install Gulp & Yarn
RUN npm install --no-color --production --global gulp-cli yarn

# Cleanup
RUN apt-get clean -y && \
 apt-get autoremove -y && \
 rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/*
